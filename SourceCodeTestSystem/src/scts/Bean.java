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
	
	/*
	
	// �닔�젙�맂 二쇱냼濡� �궡�슜 媛깆떊�쓣 �쐞�븳 硫붿꽌�뱶
	public boolean updateDB(AddrBook addrbook) {
		connect();
		
		String sql ="update addrbook set ab_name=?, ab_email=?, ab_birth=?, ab_tel=?, ab_comdept=?, ab_memo=? where ab_id=?";		
		 
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,addrbook.getAb_name());
			pstmt.setString(2,addrbook.getAb_email());
			pstmt.setString(3, addrbook.getAb_birth());
			pstmt.setString(4,addrbook.getAb_tel());
			pstmt.setString(5,addrbook.getAb_comdept());
			pstmt.setString(6,addrbook.getAb_memo());
			pstmt.setInt(7,addrbook.getAb_id());
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
	
	// �듅�젙 二쇱냼濡� 寃뚯떆湲� �궘�젣 硫붿꽌�뱶
	public boolean deleteDB(int gb_id) {
		connect();
		
		String sql ="delete from addrbook where ab_id=?";
		
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,gb_id);
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
*/
}