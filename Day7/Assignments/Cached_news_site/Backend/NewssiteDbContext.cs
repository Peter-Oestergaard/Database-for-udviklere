using Microsoft.EntityFrameworkCore;

namespace Backend;

public class NewssiteDbContext(DbContextOptions<NewssiteDbContext> options) : DbContext(options)
{
    public DbSet<User> Users => Set<User>();
    public DbSet<Article> Articles => Set<Article>();
    public DbSet<Comment> Comments => Set<Comment>();
}