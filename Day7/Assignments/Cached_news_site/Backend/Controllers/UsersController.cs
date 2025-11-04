using Backend.Repositories;
using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class UsersController(UserRepository userssDb) : Controller
{
    [HttpGet("{id:int}", Name = "GetUserById")]
    public ActionResult<IEnumerable<User>> Get(int id)
    {
        List<User> users = userssDb.Users;

        return Ok(users);
    }
}