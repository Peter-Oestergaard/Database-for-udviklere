using System.Text.Json;
using Microsoft.Extensions.Options;
using StackExchange.Redis;

namespace Backend.Repositories;

public class ArticleRepository(
    NewssiteDbContext db,
    IConnectionMultiplexer redis,
    IOptions<CachingSettings> cachingSettings)
{
    private const string Articleskey = "article";
    private readonly IDatabase _cache = redis.GetDatabase();
    private readonly CachingSettings _cachingSettings = cachingSettings.Value;

    public IQueryable<Article> Articles
    {
        get
        {
            if (!_cachingSettings.Disable)
            {
                List<Article> cachedArticles = GetFromCache();

                if (cachedArticles.Count != 0)
                {
                    return cachedArticles.AsQueryable();
                }
            }

            IQueryable<Article> articles = db.Articles.AsQueryable();

            if (!_cachingSettings.Disable && articles.Any())
            {
                foreach (Article article in articles)
                {
                    _cache.StringSet($"{Articleskey}:{article.Id}", JsonSerializer.Serialize(article),
                        _cachingSettings.TimeoutSeconds == 0
                            ? null
                            : TimeSpan.FromSeconds(_cachingSettings.TimeoutSeconds));
                }
            }

            return articles;
        }
    }

    private List<Article> GetFromCache(int? id = null)
    {
        List<Article> articles = [];
        if (id == null)
        {
            IEnumerable<RedisKey> keys = redis.GetServer(redis.GetEndPoints().First()).Keys(pattern: $"{Articleskey}:*");
            foreach (RedisKey key in keys)
            {
                RedisValue value = _cache.StringGet(key);
                if (value != RedisValue.Null)
                {
                    Article article = JsonSerializer.Deserialize<Article>(value!)!;
                    articles.Add(article);
                }
            }
        }
        else
        {
            RedisValue value = _cache.StringGet($"{Articleskey}:{id}");
            if (value != RedisValue.Null)
            {
                Article article = JsonSerializer.Deserialize<Article>(value!)!;
                articles.Add(article);
            }
        }
        
        return articles;
    }

    public Article? ArticleById(int id)
    {
        if (!_cachingSettings.Disable)
        {
            Article? cachedArticle = GetFromCache(id).FirstOrDefault();

            if (cachedArticle is not null)
            {
                return cachedArticle;
            }
        }

        Article? article = db.Articles.SingleOrDefault(a => a.Id == id);

        if (!_cachingSettings.Disable)
        {
                _cache.StringSet($"{Articleskey}:{id}", JsonSerializer.Serialize(article),
                    _cachingSettings.TimeoutSeconds == 0
                        ? null
                        : TimeSpan.FromSeconds(_cachingSettings.TimeoutSeconds));
        }

        return article;
    }
}