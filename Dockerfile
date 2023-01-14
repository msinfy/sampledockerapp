#Depending on the operating system of the host machines(s) that will build or run the containers, the image specified in the FROM statement may need to be changed.
#For more information, please see https://aka.ms/containercompat

#FROM mcr.microsoft.com/dotnet/core/aspnet:2.1-nanoserver-1903 AS base
FROM  mcr.microsoft.com/dotnet/sdk:6.0
# mcr.microsoft.com/dotnet/aspnet:6.0 as base
WORKDIR /app
EXPOSE 80
EXPOSE 443

# .NET Core SDK
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build
#FROM mcr.microsoft.com/dotnet/aspnet:6.0 as build
WORKDIR /src


#COPY dockerapp/dockerapp/dockerapp.csproj  dockerapp
COPY /dockerapp/*.sln .
COPY /dockerapp/dockerapp/dockerapp.csproj  .
#--------------------------------------------------------------------------------------------------------------------
RUN pwd
RUN ls -lrt
RUN dotnet sdk check

#-------------------------------------------------------------------------------------------------------------------------------

#RUN dotnet restore --use-current-runtime  
RUN dotnet restore "/src/dockerapp/dockerapp.csproj"

COPY . .
WORKDIR "/src/dockerapp"
RUN dotnet build "dockerapp.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "dockerapp.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "dockerapp.dll"]
