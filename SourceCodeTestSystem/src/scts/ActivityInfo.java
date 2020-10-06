package scts;

import java.util.Date;

public class ActivityInfo {
	private String courseidforclass;
	private int activityid;
	private int activitytype;
	private String activityname;
	private boolean oopcheck;
	private Date starttime; 
	private Date endtime;
	private boolean ispassword;
	private String pw;
	private double maxscore;
	private double score;
	private String comment;
	private boolean isopened;
	private int language;
	private int problemcount;
	
	public int getProblemcount() {
		return problemcount;
	}
	public void setProblemcount(int problemcount) {
		this.problemcount = problemcount;
	}
	public int getLanguage() {
		return language;
	}
	public void setLanguage(int language) {
		this.language = language;
	}
	public String getCourseidforclass() {
		return courseidforclass;
	}
	public void setCourseidforclass(String courseidforclass) {
		this.courseidforclass = courseidforclass;
	}
	public int getActivityid() {
		return activityid;
	}
	public void setActivityid(int activityid) {
		this.activityid = activityid;
	}
	public int getActivitytype() {
		return activitytype;
	}
	public void setActivitytype(int activitytype) {
		this.activitytype = activitytype;
	}
	public String getActivityname() {
		return activityname;
	}
	public void setActivityname(String activityname) {
		this.activityname = activityname;
	}
	public boolean isOopcheck() {
		return oopcheck;
	}
	public void setOopcheck(boolean oopcheck) {
		this.oopcheck = oopcheck;
	}
	public Date getStarttime() {
		return starttime;
	}
	public void setStarttime(Date starttime) {
		this.starttime = starttime;
	}
	public Date getEndtime() {
		return endtime;
	}
	public void setEndtime(Date endtime) {
		this.endtime = endtime;
	}
	public boolean isIspassword() {
		return ispassword;
	}
	public void setIspassword(boolean ispassword) {
		this.ispassword = ispassword;
	}
	public String getPw() {
		return pw;
	}
	public void setPw(String pw) {
		this.pw = pw;
	}
	public double getMaxscore() {
		return maxscore;
	}
	public void setMaxscore(double maxscore) {
		this.maxscore = maxscore;
	}
	public double getScore() {
		return score;
	}
	public void setScore(double score) {
		this.score = score;
	}
	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}
	public boolean isIsopened() {
		return isopened;
	}
	public void setIsopened(boolean isopened) {
		this.isopened = isopened;
	}
}
