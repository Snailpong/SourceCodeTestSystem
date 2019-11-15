package scts;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Date;

public class Bean { 
	Connection conn = null;
	PreparedStatement pstmt = null;

	String jdbc_driver = "com.mysql.cj.jdbc.Driver";
	String jdbc_url = "jdbc:mysql://127.0.0.1:3306/scts?characterEncoding=UTF-8&serverTimezone=Asia/Seoul"; 
	
	void connect() {
		try {
			Class.forName(jdbc_driver);
			conn = DriverManager.getConnection(jdbc_url,"user1","1234");
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	void disconnect() {
		if(pstmt != null) {
			try {
				pstmt.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		} 
		if(conn != null) {
			try {
				conn.close();
			} catch (SQLException e) {
				e.printStackTrace();
			}
		}
	}
	
	public Member checkID(String id, String pw) {
		connect();
		Member member = new Member();
		member.setId(id);
		String sql = "select * from members where id="+id;
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			rs.next();
			String getpw = rs.getString("pw");
			if(getpw.equals(SHA256.encryptSHA256(pw)))
				member.setName(rs.getString("name"));
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return member;
	}
	
	public ArrayList<Course> getCoursesForStudent(String studentid) {
		connect();
		ArrayList<Course> courses = new ArrayList<Course>();
		String sql = "select * from studentcourse natural join course where id=" + studentid
				+ " order by courseidforclass desc";
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				Course course = new Course();
				
				course.setCourseIdForClass(rs.getString("courseidforclass"));
				course.setCourseClassNum(rs.getString("courseidforclass").substring(16));
				course.setCourseId(rs.getString("courseidforclass").substring(8, 15));
				course.setCourseName(rs.getString("coursename"));
				course.setCourseSemester(rs.getString("courseidforclass").substring(5, 7));
				course.setCourseYear(rs.getString("courseidforclass").substring(0, 4));
				course.setProfessorId(rs.getString("professorid"));
				
				courses.add(course);
			}
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return courses;
	}
	
	public ArrayList<ActivityInfo> getActivityInfoForStudent
	    (String studentid, String courseidforclass) {
		ArrayList<ActivityInfo> activityInfo = new ArrayList<ActivityInfo>();
		connect();
		String sql = "select a.*, b.score, b.comment, b.isopened from courseactivity as a left join grade as b" + 
				" on a.courseidforclass = b.courseidforclass and a.activityid = b.activityid" + 
				" where a.courseidforclass = '" + courseidforclass + "' and b.id = '" + studentid + "'  order by a.activityid";
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				ActivityInfo info = new ActivityInfo();
			
				info.setCourseidforclass(rs.getString("courseidforclass"));
				info.setActivityid(rs.getInt("activityid"));
				info.setActivitytype(rs.getInt("activitytype"));
				info.setActivityname(rs.getString("activityname"));
				info.setOopcheck(rs.getBoolean("oopcheck"));
				info.setStarttime(rs.getTimestamp("starttime"));
				info.setEndtime(rs.getTimestamp("endtime"));
				info.setIspassword(rs.getBoolean("ispassword"));
				info.setPw(rs.getString("pw"));
				info.setMaxscore(rs.getDouble("maxscore"));
				info.setScore(rs.getDouble("score"));
				info.setComment(rs.getString("comment"));
				info.setIsopened(rs.getBoolean("isopened"));
				info.setLanguage(rs.getInt("language"));
				info.setProblemcount(rs.getInt("numberofproblem"));
				
				activityInfo.add(info);
			}
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return activityInfo;
	}

	public int makeProblem(String courseidforclass, int test_num, 
			boolean auto_scoring_yn, String problemname) {
		connect();
		int count = 0;
		String sql 
		 = "insert into problem(courseidforclass,testcasenum,autocheck,problemname) values(?,?,?,?)";
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, courseidforclass);
			pstmt.setInt(2, test_num);
			pstmt.setBoolean(3, auto_scoring_yn);
			pstmt.setString(4, problemname);
			
			pstmt.executeUpdate();
			
			pstmt = conn.prepareStatement("SELECT COUNT(*) FROM problem where courseidforclass='"
					+ courseidforclass + "'");
			ResultSet rs = pstmt.executeQuery();
			rs.next();
			count = rs.getInt("COUNT(*)");
		} catch (SQLException e) {
			e.printStackTrace();
			return -1;
		}
		finally {
			disconnect();
		}
		return count;
	}
	
	public ArrayList<Problem> getProblems(String courseidforclass) {
		connect();
		ArrayList<Problem> problems = new ArrayList<Problem>();
		String sql = "select * from problem where courseidforclass='"+courseidforclass+"'";
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				Problem problem = new Problem();
				
				problem.setCourseidforclass(rs.getString("courseidforclass"));
				problem.setProblemnum(rs.getInt("problemnum"));
				problem.setTestcasenum(rs.getInt("testcasenum"));
				problem.setAutocheck(rs.getBoolean("autocheck"));
				problem.setProblemname(rs.getString("problemname"));
				
				problems.add(problem);
			}
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return problems;
	}
	
	public boolean makeActivity(String courseidforclass, String activityname, String password, 
			int language, boolean analysis_yn, boolean ispassword, Date starttime, Date endtime, 
			int numberofproblem, double maxscore, ArrayList<Integer> probnums, ArrayList<Double> maxscores, String id) {
		connect();
		String sql 
		 = "insert into courseactivity(courseidforclass,activitytype,activityname,oopcheck,starttime,"
		 		+ "endtime,ispassword,pw,maxscore,language, numberofproblem) values(?,?,?,?,?,?,?,?,?,?,?)";
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, courseidforclass);
			pstmt.setInt(2, 0);
			pstmt.setString(3, activityname);
			pstmt.setBoolean(4, analysis_yn);
			pstmt.setTimestamp(5, new Timestamp(starttime.getTime()));
			pstmt.setTimestamp(6, new Timestamp(endtime.getTime()));
			pstmt.setBoolean(7, ispassword);
			pstmt.setString(8, password);
			pstmt.setDouble(9, maxscore);
			pstmt.setInt(10, language);
			pstmt.setInt(11, numberofproblem);
			
			pstmt.executeUpdate();
			
			pstmt = conn.prepareStatement("SELECT COUNT(*) FROM courseactivity where courseidforclass='" + courseidforclass + "'");
			ResultSet rs = pstmt.executeQuery();
			rs.next();
			int count = rs.getInt("COUNT(*)");
			rs.close();
			
			for(int i=0; i!=numberofproblem; ++i) {
				pstmt = conn.prepareStatement("insert into activityproblem(courseidforclass,"
						+ " activityid, problemnum, maxscore) values(?,?,?,?)");
				pstmt.setString(1, courseidforclass);
				pstmt.setInt(2, count);
				pstmt.setInt(3, probnums.get(i));
				pstmt.setDouble(4, maxscores.get(i));
				pstmt.executeUpdate();
			}
			
			pstmt = conn.prepareStatement("select id from studentcourse where courseidforclass='" + courseidforclass + "'");
			rs = pstmt.executeQuery();
			while(rs.next()) {
				String student_id = rs.getString("id");
				
				pstmt = conn.prepareStatement("insert into grade(id, courseidforclass, activityid, score, isopened) values(?,?,?,?,?)");
				pstmt.setString(1, student_id);
				pstmt.setString(2, courseidforclass);
				pstmt.setInt(3, count);
				pstmt.setInt(4, 0);
				pstmt.setBoolean(5, false);
				pstmt.executeUpdate();
			}
			rs.close();
			
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
		finally {
			disconnect();
		}
		return true;
	}
	
	public ArrayList<ActivityProblem> getActivityProblem(String courseidforclass, int activityid){
		ArrayList<ActivityProblem> activityproblems = new ArrayList<ActivityProblem>();
		String sql = "select * from activityproblem natural join problem "
				+ "where courseidforclass='" + courseidforclass + "' and activityid=" + activityid;
		connect();
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				ActivityProblem activityproblem = new ActivityProblem();
				
				activityproblem.setCourseidforclass(rs.getString("courseidforclass"));
				activityproblem.setProblemnum(rs.getInt("problemnum"));
				activityproblem.setActivityid(rs.getInt("activityid"));
				activityproblem.setProblemid(rs.getInt("problemid"));
				activityproblem.setMaxscore(rs.getDouble("maxscore"));
				activityproblem.setTestcasenum(rs.getInt("testcasenum"));
				activityproblem.setAutocheck(rs.getBoolean("autocheck"));
				activityproblem.setProblemname(rs.getString("problemname"));
				
				activityproblems.add(activityproblem);
			}
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return activityproblems;
	}
	
	public String langInt2Str(int language) {
		switch(language) {
		case 0: return ".c";
		case 1: return ".cpp";
		case 2: return ".java";
		default: return ".py";
		}
	}
	
	public String langInt2Opt(int language) {
		switch(language) {
		case 0: return "c_cpp";
		case 1: return "c_cpp";
		case 2: return "java";
		default: return "python";
		
		}
	}
	
	public String getExample(int language) {
		switch(language) {
		case 0: return "#include <stdio.h>\nint main(){\n\n    printf(\"Hello World\\n\");\n    return 0;\n}";
		case 1: return "#include <iostream>\nusing namespace std;\n\nint main(){\n\n    cout << \"Hello World\";\n    return 0;\n}";
		case 2: return "public class Main{\r\n" + 
				"	public static void main(String args[]){\r\n" + 
				"		System.out.println(\"Hello World\");\r\n" + 
				"	}\r\n" + 
				"}";
		default: return "print('Hello World')";
		}
	}
	
	public boolean insertScore(String id, String courseidforclass, int activityid, int problemid, double score) {
		connect();
		double sumScore = 0;
		String sql 
		 = "insert into activityproblemscore(courseidforclass, activityid, problemid, id, score) values(?,?,?,?,?) on duplicate key update score=?";
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, courseidforclass);
			pstmt.setInt(2, activityid);
			pstmt.setInt(3, problemid);
			pstmt.setString(4, id);
			pstmt.setDouble(5, score);
			pstmt.setDouble(6, score);
			pstmt.executeUpdate();
			
			pstmt = conn.prepareStatement("SELECT SUM(score) FROM activityproblemscore where courseidforclass=? and activityid=? and id=?");
			pstmt.setString(1, courseidforclass);
			pstmt.setInt(2, activityid);
			pstmt.setString(3, id);
			ResultSet rs = pstmt.executeQuery();
			rs.next();
			sumScore = rs.getDouble("SUM(score)");
			
			pstmt = conn.prepareStatement("insert into grade(id, courseidforclass, activityid, score) values(?,?,?,?) on duplicate key update score=?");
			pstmt.setString(1, id);
			pstmt.setString(2, courseidforclass);
			pstmt.setInt(3, activityid);
			pstmt.setDouble(4, sumScore);
			pstmt.setDouble(5, sumScore);
			pstmt.executeUpdate();
		} catch (SQLException e) {
			e.printStackTrace();
			return false;
		}
		finally {
			disconnect();
		}
		return true;
	}
	
	public double getProblemScore(String id, String courseidforclass, int activityid, int problemid) {
		double sumScore;
		connect();
		String sql 
		 = "SELECT SUM(score) FROM activityproblemscore where courseidforclass=? and activityid=? and problemid=? and id=?";
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, courseidforclass);
			pstmt.setInt(2, activityid);
			pstmt.setInt(3, problemid);
			pstmt.setString(4, id);
			ResultSet rs = pstmt.executeQuery();
			rs.next();
			sumScore = rs.getDouble("SUM(score)");
		} catch (SQLException e) {
			e.printStackTrace();
			return 0.0;
		}
		finally {
			disconnect();
		}
		return sumScore;
	}

	public ArrayList<ScoreInfo> getActivityResult(String courseidforclass, int activityid) {
		connect();
		ArrayList<ScoreInfo> scores = new ArrayList<ScoreInfo>();
		String sql = "select g.id, g.score, m.name from grade as g natural join members as m "
				+ "where g.courseidforclass='" + courseidforclass +"' and g.activityid=" + activityid + " order by m.name";
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				ScoreInfo score = new ScoreInfo();
				
				score.setId(rs.getString("id"));
				score.setScore(rs.getDouble("score"));
				score.setName(rs.getString("name"));
				
				scores.add(score);
			}
			rs.close();
		} catch(SQLException e) {
			e.printStackTrace();
		} finally {
			disconnect();
		}
		return scores;
	}
}