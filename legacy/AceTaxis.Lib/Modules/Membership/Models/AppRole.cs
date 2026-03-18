using Microsoft.AspNetCore.Identity;

public class AppRole : IdentityRole<int>
{
    public AppRole() { }

    public AppRole(string name)
    {
        Name = name;
    }
}
