package scts;

public class Course {
	private String courseIdForClass;
	private String courseYear;
	private String courseSemester;
	private String courseId;
	private String courseClassNum;
	private String courseName;
	private String professorId;
	
	public String getCourseIdForClass() {
		return courseIdForClass;
	}
	public void setCourseIdForClass(String courseIdForClass) {
		this.courseIdForClass = courseIdForClass;
	}
	public String getCourseYear() {
		return courseYear;
	}
	public void setCourseYear(String courseYear) {
		this.courseYear = courseYear;
	}
	public String getCourseSemester() {
		return courseSemester;
	}
	public void setCourseSemester(String courseSemester) {
		this.courseSemester = courseSemester;
	}
	public String getCourseId() {
		return courseId;
	}
	public void setCourseId(String courseId) {
		this.courseId = courseId;
	}
	public String getCourseClassNum() {
		return courseClassNum;
	}
	public void setCourseClassNum(String courseClassNum) {
		this.courseClassNum = courseClassNum;
	}
	public String getCourseName() {
		return courseName;
	}
	public void setCourseName(String courseName) {
		this.courseName = courseName;
	}
	public String getProfessorId() {
		return professorId;
	}
	public void setProfessorId(String professorId) {
		this.professorId = professorId;
	}
	
	public String getSemesterString() {
		if(courseSemester.equals("00")) return "1";
		if(courseSemester.equals("01")) return "여름";
		if(courseSemester.equals("10")) return "2";
		if(courseSemester.equals("11")) return "겨울";
		return "";
	}
	
	
	
	
}
