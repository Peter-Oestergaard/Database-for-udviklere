using Microsoft.AspNetCore.Mvc;

namespace Backend.Controllers;

[ApiController]
[Route("[controller]")]
public class ResetController : Controller
{
    [HttpPost(Name = "Reset")]
    public IActionResult Reset()
    {
        return Ok("Done deal!");
    }
}