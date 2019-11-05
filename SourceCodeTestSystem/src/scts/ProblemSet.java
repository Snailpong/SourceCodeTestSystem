package scts;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class ProblemSet {
	private Connection conn;
    private PreparedStatement pstmt;  
    private ResultSet rs;
    
    public ProblemSet() {
        try {
            String dbURL="jdbc:mysql://127.0.0.1:3306/SourceCodeTextSystem?serverTimezone=UTC";                             
            String dbID="root";
            String dbPassword="1912";
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(dbURL,dbID,dbPassword);
        } catch(Exception e) {
        	e.printStackTrace();
        }
    }
            
           /*
            
    public int join(User user) {
        String SQL= "INSERT INTO USER VALUES(?, ?, ?, ?, ?) ";
        try {
            pstmt = conn.prepareStatement(SQL);
            pstmt.setString(1,user.getUserID());
            pstmt.setString(2,user.getUserPassword());
            pstmt.setString(3,user.getUserName());
            pstmt.setString(4,user.getUserGender());
            pstmt.setString(5,user.getUserEmail());
            return pstmt.executeUpdate();
        }
        catch(Exception e) {
            e.printStackTrace();
        }
        return -1;
    }*/
}
