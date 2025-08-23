FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

COPY ["tripTicket.Subscriber/tripTicket.Subscriber.csproj", "tripTicket.Subscriber/"]
COPY ["tripTicket.Model/tripTicket.Model.csproj", "tripTicket.Model/"]

WORKDIR /app/tripTicket.Subscriber
RUN dotnet restore

COPY . .

RUN dotnet build "tripTicket.Subscriber/tripTicket.Subscriber.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS runtime
WORKDIR /app
COPY --from=build /app/build .

ENTRYPOINT ["dotnet", "tripTicket.Subscriber.dll"]
