using Backend;
using Backend.Repositories;
using Microsoft.EntityFrameworkCore;
using StackExchange.Redis;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDbContext<NewssiteDbContext>(options =>
{
    options.UseNpgsql("Host=localhost;Port=5432;Database=newssite;Username=root;Password=root");
});
builder.Services.AddScoped<ArticleRepository>();
builder.Services.AddScoped<CommentRepository>();
builder.Services.AddScoped<UserRepository>();

builder.Services.AddSingleton<IConnectionMultiplexer>(_ => ConnectionMultiplexer.Connect("localhost:6379"));

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();