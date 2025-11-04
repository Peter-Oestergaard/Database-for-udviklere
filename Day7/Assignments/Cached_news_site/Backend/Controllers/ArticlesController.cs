using Backend.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class ArticlesController(ArticleRepository articlesDb, CommentRepository commentsDb) : ControllerBase
{
    [HttpGet(Name = "GetArticles")]
    public ActionResult<IEnumerable<Article>> Get()
    {
        List<Article> articles = articlesDb.Articles;

        return Ok(articles);
    }

    [HttpGet("{id:int}", Name = "GetArticleById")]
    public ActionResult<Article> Get(int id)
    {
        Article? article = articlesDb.Articles.FirstOrDefault(a => a.Id == id);

        if (article is null)
        {
            return NotFound();
        }

        IEnumerable<Comment> comments = commentsDb.Comments.Where(c => article.Id == c.ArticleId);

        return Ok(
            new { article, comments }
        );
    }
}