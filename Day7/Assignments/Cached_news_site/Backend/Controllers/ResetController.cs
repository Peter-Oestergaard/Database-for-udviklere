using Microsoft.AspNetCore.Mvc;
using StackExchange.Redis;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class ResetController(IConnectionMultiplexer redis) : Controller
{
    private readonly IDatabase _cache = redis.GetDatabase();

    [HttpPost(Name = "Reset")]
    public IActionResult Reset()
    {
        // Remove all articles
        var articles = redis.GetServer(redis.GetEndPoints().First()).Keys(pattern: "article:*").ToList();
        foreach (RedisKey key in articles)
        {
            _cache.KeyDelete(key);
        }
        
        // Remove each article's comment index list
        var articleComments = redis.GetServer(redis.GetEndPoints().First()).Keys(pattern: "article:*:comments").ToList();
        foreach (RedisKey key in articleComments)
        {
            _cache.KeyDelete(key);
        }
        
        // Remove all comments
        var comments = redis.GetServer(redis.GetEndPoints().First()).Keys(pattern: "comment:*").ToList();
        foreach (RedisKey key in comments)
        {
            _cache.KeyDelete(key);
        }
        
        return Ok("Done deal!");
    }
}