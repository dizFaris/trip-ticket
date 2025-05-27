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

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddTransient<ITripService, TripService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<IBookmarkService, BookmarkService>();
builder.Services.AddTransient<IPurchaseService, PurchaseService>();
builder.Services.AddTransient<IUserActivityService, UserActivityService>();

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
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("TripTicketDB");
builder.Services.AddDbContext<TripTicketDbContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMapster();

builder.Services.AddHangfire(configuration => configuration
    .UseSqlServerStorage(connectionString));

builder.Services.AddHangfireServer();

var app = builder.Build();

app.UseHangfireDashboard();

RecurringJob.AddOrUpdate<TripStatusUpdater>(
    "UpdateTripStatuses",                   
    updater => updater.UpdateTripsAndPurchases(),
    Cron.Minutely);

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
