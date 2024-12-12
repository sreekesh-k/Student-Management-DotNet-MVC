using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using Student_Management_DotNet_MVC.Models.Entities;

namespace Student_Management_DotNet_MVC.Data
{
    public class ApplicationDbContext : IdentityDbContext
    {
        public ApplicationDbContext(DbContextOptions <ApplicationDbContext> options): base(options)
        {
            
        }

        public DbSet<Student> Students { get; set; }

    }
}
    