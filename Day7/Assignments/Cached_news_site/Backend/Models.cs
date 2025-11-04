using System.ComponentModel.DataAnnotations.Schema;

namespace Backend;

[Table("users")]
public class User
{
    [Column("id")]
    public int Id { get; set; }
    [Column("name")]
    public string Name { get; set; } = null!;
    [Column("email")]
    public string Email { get; set; } = null!;
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}

[Table("articles")]
public class Article
{
    [Column("id")]
    public int Id { get; set; }
    [Column("title")]
    public string Title { get; set; } = null!;
    [Column("content")]
    public string Content { get; set; } = null!;
    [Column("author_id")]
    public int AuthorId { get; set; }
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}

[Table("comments")]
public class Comment
{
    [Column("id")]
    public int Id { get; set; }
    [Column("article_id")]
    public int ArticleId { get; set; }
    [Column("user_id")]
    public int UserId { get; set; }
    [Column("content")]
    public string Content { get; set; } = null!;
    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}