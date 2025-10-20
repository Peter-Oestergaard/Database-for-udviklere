using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class UsersController : Controller
{
    private static readonly string[] Summaries =
    [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"
    ];
    
    [HttpGet("{id:int}", Name = "GetUserById")]
    public string Get(int id)
    {
        return Summaries.First();
    }
}