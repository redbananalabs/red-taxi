# =============================================================================
# Red Taxi Platform - Multi-stage Docker Build
# =============================================================================

# Stage 1: Restore dependencies (cached layer)
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS restore
WORKDIR /src

COPY src/RedTaxi.sln ./
COPY src/RedTaxi.Domain/RedTaxi.Domain.csproj RedTaxi.Domain/
COPY src/RedTaxi.Shared/RedTaxi.Shared.csproj RedTaxi.Shared/
COPY src/RedTaxi.Application/RedTaxi.Application.csproj RedTaxi.Application/
COPY src/RedTaxi.Infrastructure/RedTaxi.Infrastructure.csproj RedTaxi.Infrastructure/
COPY src/RedTaxi.API/RedTaxi.API.csproj RedTaxi.API/
COPY src/RedTaxi.Blazor/RedTaxi.Blazor.csproj RedTaxi.Blazor/
COPY src/RedTaxi.WebPortal/RedTaxi.WebPortal.csproj RedTaxi.WebPortal/
COPY src/RedTaxi.TenantAdmin/RedTaxi.TenantAdmin.csproj RedTaxi.TenantAdmin/

RUN dotnet restore RedTaxi.sln

# Stage 2: Build and publish
FROM restore AS build
COPY src/ ./
RUN dotnet build RedTaxi.sln -c Release --no-restore

# Publish API
FROM build AS publish-api
RUN dotnet publish RedTaxi.API/RedTaxi.API.csproj -c Release -o /app/api --no-build

# Publish Blazor
FROM build AS publish-blazor
RUN dotnet publish RedTaxi.Blazor/RedTaxi.Blazor.csproj -c Release -o /app/blazor --no-build

# =============================================================================
# Stage 3a: API Runtime
# =============================================================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS api-final

RUN addgroup -S redtaxi && adduser -S redtaxi -G redtaxi

WORKDIR /app
COPY --from=publish-api /app/api .

RUN chown -R redtaxi:redtaxi /app

USER redtaxi

ENV ASPNETCORE_URLS=http://+:5001
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_EnableDiagnostics=0

EXPOSE 5001

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5001/health || exit 1

ENTRYPOINT ["dotnet", "RedTaxi.API.dll"]

# =============================================================================
# Stage 3b: Blazor Runtime
# =============================================================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0-alpine AS blazor-final

RUN addgroup -S redtaxi && adduser -S redtaxi -G redtaxi

WORKDIR /app
COPY --from=publish-blazor /app/blazor .

RUN chown -R redtaxi:redtaxi /app

USER redtaxi

ENV ASPNETCORE_URLS=http://+:5002
ENV ASPNETCORE_ENVIRONMENT=Production
ENV DOTNET_EnableDiagnostics=0

EXPOSE 5002

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5002/health || exit 1

ENTRYPOINT ["dotnet", "RedTaxi.Blazor.dll"]
