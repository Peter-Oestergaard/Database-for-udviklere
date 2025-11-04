using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class UsersController(NewssiteDbContext db) : Controller
{
    [HttpGet("{id:int}", Name = "GetUserById")]
    public async Task<ActionResult<IEnumerable<User>>> Get(int id)
    {
        List<User> users = await db.Users.ToListAsync();

        return Ok(users);
    }
}