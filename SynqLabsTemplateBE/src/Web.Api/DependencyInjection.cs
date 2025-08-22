using Web.Api.Infrastructure;

namespace Web.Api;

public static class DependencyInjection
{
    public static IServiceCollection AddPresentation(this IServiceCollection services)
    {
        services.AddEndpointsApiExplorer();

        // Add NSwag services for document generation (with unique document name)
        services.AddOpenApiDocument(config =>
        {
            config.DocumentName = "nswag";
            config.Title = "SynqLabs Template API"; // !!! Modify this to your API name
            config.Version = "v1.0";
        });

        services.AddControllers();

        services.AddExceptionHandler<GlobalExceptionHandler>();
        services.AddProblemDetails();

        return services;
    }
}
