using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class ArticlesController : ControllerBase
{
    private static readonly string[] Summaries =
    [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J"
    ];

    [HttpGet(Name = "GetArticles")]
    public IEnumerable<string> Get()
    {
        return Summaries;
    }
}