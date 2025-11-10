namespace Backend;

public class CachingSettings
{
    public bool Disable { get; set; } = false;
    public long TimeoutSeconds { get; set; } = 0;
};