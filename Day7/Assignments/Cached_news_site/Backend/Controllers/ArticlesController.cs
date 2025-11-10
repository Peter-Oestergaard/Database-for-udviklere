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
        return Ok(articlesDb.Articles);
    }

    [HttpGet("{id:int}", Name = "GetArticleById")]
    public ActionResult<Article> Get(int id)
    {
        Article? article = articlesDb.ArticleById(id);

        if (article is null)
        {
            return NotFound();
        }

        IEnumerable<Comment> comments = commentsDb.CommentsForArticle(id: article.Id);

        return Ok(
            new { article, comments }
        );
    }
}