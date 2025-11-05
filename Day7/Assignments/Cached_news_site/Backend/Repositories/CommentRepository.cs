using System.Text.Json;
using StackExchange.Redis;

namespace Backend.Repositories;

public class CommentRepository(NewssiteDbContext db, IConnectionMultiplexer redis)
{
    private const string Commentskey = "comments";
    private readonly IDatabase _cache = redis.GetDatabase();

    // public IQueryable<Comment> Comments
    // {
    //     get
    //     {
    //         var commentJson = _cache.HashG
    //         return db.Comments.AsQueryable();
    //     }
    // }

    public IEnumerable<Comment> CommentsForArticle(int id)
    {
        RedisValue[] commentIds = _cache.ListRange($"article:{id}:comments");

        try
        {

            if (commentIds.Length != 0)
            {
                List<Comment> cachedComments = [];
                foreach (RedisValue commentId in commentIds)
                {
                    RedisValue commentJson = _cache.StringGet($"comment:{commentId}");
                    if (commentJson != RedisValue.Null)
                    {
                        Comment? comment = JsonSerializer.Deserialize<Comment>(commentJson!);
                        if (comment is not null)
                        {
                            cachedComments.Add(comment);
                        }
                        else
                        {
                            throw new Exception();
                        }
                    }
                    else
                    {
                        throw new Exception();
                    }
                }

                return cachedComments;
            }
        }
        catch (Exception)
        {
            // Whatever went wrong we clear the cache and continue with the database instead
            _cache.KeyDelete($"article:{id}:comments");
        }

        IQueryable<Comment> comments = db.Comments.Where(c => c.ArticleId == id);
        
        foreach (Comment comment in comments)
        {
            _cache.ListRightPush($"article:{id}:comments", comment.Id);
            _cache.StringSet($"comment:{comment.Id}", JsonSerializer.Serialize(comment), TimeSpan.FromSeconds(10));
        }
        
        return comments;
    }
}