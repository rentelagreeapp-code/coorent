# Multi-stage build for .NET 8 Web API
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build-env
WORKDIR /app

# Copy csproj and restore dependencies
COPY CooRent.Api/*.csproj ./CooRent.Api/
RUN dotnet restore CooRent.Api/CooRent.Api.csproj

# Copy remaining source code and build
COPY CooRent.Api/ ./CooRent.Api/
WORKDIR /app/CooRent.Api
RUN dotnet publish -c Release -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build-env /app/CooRent.Api/out .

# Expose port and start API
ENV ASPNETCORE_URLS=http://*:10000
EXPOSE 10000
ENTRYPOINT ["dotnet", "CooRent.Api.dll"]
