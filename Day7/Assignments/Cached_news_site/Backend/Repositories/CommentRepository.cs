namespace Backend.Repositories;

public class CommentRepository(NewssiteDbContext db)
{
    public List<Comment> Comments => db.Comments.ToList();
}