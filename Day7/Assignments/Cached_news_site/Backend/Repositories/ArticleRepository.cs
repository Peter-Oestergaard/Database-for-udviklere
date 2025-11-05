using System.Text.Json;
using NRedisStack.RedisStackCommands;
using StackExchange.Redis;

namespace Backend.Repositories;

public class ArticleRepository(NewssiteDbContext db, IConnectionMultiplexer redis)
{
    private const string Articleskey = "articles";
    private readonly IDatabase _cache = redis.GetDatabase();

    public IQueryable<Article> Articles
    {
        get
        {
            RedisValue articlesJson = _cache.StringGet(Articleskey);
            if (articlesJson != RedisValue.Null)
            {
                List<Article>? cachedArticles = JsonSerializer.Deserialize<List<Article>>(articlesJson!);
                if (cachedArticles is not null && cachedArticles.Count > 0)
                {
                    return cachedArticles.AsQueryable();
                }
            }

            IQueryable<Article> articles = db.Articles.AsQueryable();

            if (articles.Any())
            {
                _cache.StringSet(Articleskey, JsonSerializer.Serialize(articles), TimeSpan.FromSeconds(10));
            }

            return articles;
        }
    }
}