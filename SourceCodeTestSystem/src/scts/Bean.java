package scts;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;

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
				" where a.courseidforclass = '" + courseidforclass + "' and b.id = '" + studentid + "'";
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
	
	public boolean makeProblem(String courseidforclass, int test_num, 
			boolean auto_scoring_yn, double maxscore, String problemname) {
		return true;
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
	
	// �떊洹� 二쇱냼濡� 硫붿떆吏� 異붽� 硫붿꽌�뱶
	public boolean insertDB(AddrBook addrbook) {
		connect();
		// sql 臾몄옄�뿴 , gb_id �뒗 �옄�룞 �벑濡� �릺誘�濡� �엯�젰�븯吏� �븡�뒗�떎.
				
		String sql ="insert into addrbook(ab_name,ab_email,ab_birth,ab_tel,ab_comdept,ab_memo) values(?,?,?,?,?,?)";
		
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1,addrbook.getAb_name());
			pstmt.setString(2,addrbook.getAb_email());
			pstmt.setString(3, addrbook.getAb_birth());
			pstmt.setString(4,addrbook.getAb_tel());
			pstmt.setString(5,addrbook.getAb_comdept());
			pstmt.setString(6,addrbook.getAb_memo());
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

	// �듅�젙 二쇱냼濡� 寃뚯떆湲� 媛��졇�삤�뒗 硫붿꽌�뱶
	public AddrBook getDB(int gb_id) {
		connect();
		
		String sql = "select * from addrbook where ab_id=?";
		AddrBook addrbook = new AddrBook();
		
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1,gb_id);
			ResultSet rs = pstmt.executeQuery();
			
			// �뜲�씠�꽣媛� �븯�굹留� �엳�쑝誘�濡� rs.next()瑜� �븳踰덈쭔 �떎�뻾 �븳�떎.
			rs.next();
			addrbook.setAb_id(rs.getInt("ab_id"));
			addrbook.setAb_name(rs.getString("ab_name"));
			addrbook.setAb_email(rs.getString("ab_email"));
			addrbook.setAb_birth(rs.getString("ab_birth"));
			addrbook.setAb_tel(rs.getString("ab_tel"));
			addrbook.setAb_comdept(rs.getString("ab_comdept"));
			addrbook.setAb_memo(rs.getString("ab_memo"));
			rs.close();
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			disconnect();
		}
		return addrbook;
	}
	
	// �쟾泥� 二쇱냼濡� 紐⑸줉�쓣 媛��졇�삤�뒗 硫붿꽌�뱶
	public ArrayList<AddrBook> getDBList() {
		connect();
		ArrayList<AddrBook> datas = new ArrayList<AddrBook>();
		
		String sql = "select * from addrbook order by ab_id desc";
		try {
			pstmt = conn.prepareStatement(sql);
			ResultSet rs = pstmt.executeQuery();
			while(rs.next()) {
				AddrBook addrbook = new AddrBook();
				
				addrbook.setAb_id(rs.getInt("ab_id"));
				addrbook.setAb_name(rs.getString("ab_name"));
				addrbook.setAb_email(rs.getString("ab_email"));
				addrbook.setAb_comdept(rs.getString("ab_comdept"));
				addrbook.setAb_birth(rs.getString("ab_birth"));
				addrbook.setAb_tel(rs.getString("ab_tel"));
				addrbook.setAb_memo(rs.getString("ab_memo"));
				datas.add(addrbook);
			}
			rs.close();
			
		} catch (SQLException e) {
			e.printStackTrace();
		}
		finally {
			disconnect();
		}
		return datas;
	}
	
	*/
}