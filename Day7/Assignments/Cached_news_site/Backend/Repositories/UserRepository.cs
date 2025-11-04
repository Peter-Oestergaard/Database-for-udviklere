namespace Backend.Repositories;

public class UserRepository(NewssiteDbContext db)
{
    public List<User> Users => db.Users.ToList();
}