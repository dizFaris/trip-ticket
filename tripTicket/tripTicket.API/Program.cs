using Hangfire;
using Mapster;
using Microsoft.EntityFrameworkCore;
using tripTicket.API.Filters;
using tripTicket.Model.Requests;
using tripTicket.Services.BackgroundServices;
using tripTicket.Services.Database;
using tripTicket.Services.Interfaces;
using tripTicket.Services.Services;
using tripTicket.Services.TripStateMachine;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using System.Net;
using System.Text.Json.Serialization;
using tripTicket.Services.PurchaseStateMachine;
using Microsoft.AspNetCore.Authentication;
using tripTicket.API;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ITripService, TripService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IBookmarkService, BookmarkService>();
builder.Services.AddTransient<IPurchaseService, PurchaseService>();
builder.Services.AddTransient<IUserActivityService, UserActivityService>();
builder.Services.AddTransient<ITransactionService, TransactionService>();
builder.Services.AddTransient<ITripStatisticService, TripStatisticService>();
builder.Services.AddTransient<ICountryService, CountryService>();
builder.Services.AddTransient<ICityService, CityService>();

// Trip state machine
builder.Services.AddTransient<BaseTripState>();
builder.Services.AddTransient<InitialTripState>();
builder.Services.AddTransient<UpcomingTripState>();
builder.Services.AddTransient<LockedTripState>();

// Purchase state machine
// Trip state machine
builder.Services.AddTransient<BasePurchaseState>();
builder.Services.AddTransient<InitialPurchaseState>();
builder.Services.AddTransient<AcceptedPurchaseState>();

builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new Microsoft.OpenApi.Models.OpenApiSecurityScheme()
    {
        Type = Microsoft.OpenApi.Models.SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new Microsoft.OpenApi.Models.OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference{Type = ReferenceType.SecurityScheme, Id = "basicAuth"}
            },
            new string[]{}
    } });

    c.OperationFilter<ClientTypeHeaderOperationFilter>();
});

var connectionString = builder.Configuration.GetConnectionString("TripTicketDB");
builder.Services.AddDbContext<TripTicketDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();

TypeAdapterConfig<tripTicket.Services.Database.User, tripTicket.Model.Models.User>.NewConfig()
    .Map(dest => dest.Roles, src => src.UserRoles.Select(ur => ur.Role.Name).ToList());

TypeAdapterConfig<CityUpdateRequest, tripTicket.Services.Database.City>
    .NewConfig()
    .IgnoreIf((src, dest) => src.Name == null, dest => dest.Name)
    .IgnoreIf((src, dest) => src.IsActive == null, dest => dest.IsActive);


TypeAdapterConfig<CountryUpdateRequest, tripTicket.Services.Database.Country>
    .NewConfig()
    .IgnoreIf((src, dest) => src.Name == null, dest => dest.Name)
    .IgnoreIf((src, dest) => src.CountryCode == null, dest => dest.CountryCode)
    .IgnoreIf((src, dest) => src.IsActive == null, dest => dest.IsActive);

builder.Services.AddAuthentication("BasicAuthentication").AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddHangfire(configuration => configuration
    .UseSqlServerStorage(connectionString));

builder.Services.AddHangfireServer();

var app = builder.Build();


// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors(
    options => options
        .SetIsOriginAllowed(x => _ = true)
        .AllowAnyMethod()
        .AllowAnyHeader()
        .AllowCredentials()
);

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var dataContext = scope.ServiceProvider.GetRequiredService<TripTicketDbContext>();
    dataContext.Database.Migrate();
}

app.UseHangfireDashboard();

RecurringJob.AddOrUpdate<TripStatusUpdater>(
    "UpdateTripStatuses",
    updater => updater.UpdateTripsAndPurchases(),
    Cron.Minutely);

app.Run();
