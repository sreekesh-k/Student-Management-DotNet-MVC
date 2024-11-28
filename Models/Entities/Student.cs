namespace Student_Management_DotNet_MVC.Models.Entities
{
    public class Student
    {
        public Guid Id { get; set; }
        public string Name { get; set; }
        public String Email { get; set; }
        public String Phone { get; set; }
        public Boolean Subscribed { get; set; }
    }
}
