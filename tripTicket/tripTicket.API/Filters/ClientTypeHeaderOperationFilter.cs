using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace tripTicket.API.Filters
{
    public class ClientTypeHeaderOperationFilter : IOperationFilter
    {
        public void Apply(OpenApiOperation operation, OperationFilterContext context)
        {
            if (operation.Parameters == null)
                operation.Parameters = new List<OpenApiParameter>();

            operation.Parameters.Add(new OpenApiParameter
            {
                Name = "X-Client-Type",
                In = ParameterLocation.Header,
                Description = "Client type: 'desktop' or 'mobile'",
                Required = true,
                Schema = new OpenApiSchema
                {
                    Type = "string",
                    Default = new Microsoft.OpenApi.Any.OpenApiString("desktop")
                }
            });
        }
    }
}
