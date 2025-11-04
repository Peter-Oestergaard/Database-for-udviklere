using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class ArticlesController(NewssiteDbContext db) : ControllerBase
{
    [HttpGet(Name = "GetArticles")]
    public async Task<ActionResult<IEnumerable<Article>>> Get()
    {
        List<Article> articles = await db.Articles.ToListAsync();

        return Ok(articles);
    }

    [HttpGet("{id:int}", Name = "GetArticleById")]
    public async Task<ActionResult<Article>> Get(int id)
    {
        Article? article = await db.Articles.FirstOrDefaultAsync(a => a.Id == id);

        if (article is null)
        {
            return NotFound();
        }

        List<Comment> comments = await db.Comments.Where(c => article.Id == c.ArticleId).ToListAsync();

        return Ok(
            new { article, comments }
        );
    }
}