using System.Globalization;
using TeamServer;

Thread.CurrentThread.CurrentCulture = CultureInfo.CreateSpecificCulture("en-US");

CultureInfo.DefaultThreadCurrentCulture = Thread.CurrentThread.CurrentCulture;

// var builder = WebApplication.CreateBuilder(args);

var builder = Host.CreateDefaultBuilder(args).ConfigureWebHostDefaults(webBuilder => {
                                                                           webBuilder.UseStartup<Startup>();
                                                                       });

// Add services to the container.

// builder.Services.AddControllers();

var app = builder.Build();

// Configure the HTTP request pipeline.

// app.UseHttpsRedirection();

// app.UseAuthorization();

// app.MapControllers();

app.Run();