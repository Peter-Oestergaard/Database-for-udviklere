using Microsoft.Extensions.Options;
using StackExchange.Redis;

namespace Backend.Repositories;

public class UserRepository(
    NewssiteDbContext db,
    IConnectionMultiplexer redis,
    IOptions<CachingSettings> cachingSettings)
{
    private readonly IDatabase _cache = redis.GetDatabase();
    private readonly CachingSettings _cachingSettings = cachingSettings.Value;

    public IQueryable<User> Users
    {
        get
        {
            IQueryable<User> users = db.Users.AsQueryable();
            return users;
        }
    }
}