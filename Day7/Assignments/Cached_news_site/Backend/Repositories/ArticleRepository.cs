namespace Backend.Repositories;

public class ArticleRepository(NewssiteDbContext db)
{
    public List<Article> Articles => db.Articles.ToList();
}