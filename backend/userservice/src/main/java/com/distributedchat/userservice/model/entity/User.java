package com.distributedchat.userservice.model.entity;

import java.time.LocalDateTime;
import java.util.UUID;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;

@Entity
@Table(name="users")
public class User {
	
	@Id
	@GeneratedValue(strategy = GenerationType.UUID)
	@Column(updatable = false, nullable = false, unique = true)
	private UUID userid;
	
	@Column(nullable = true, unique = true)
	@Email(message = "Invalid Format")
	private String email;
	
	@Column(nullable = true)
	@JsonIgnore
	private String password;
	
	@Column(nullable = false)
	private String fullname;
	
	@Column(unique = true, nullable = true)
	private String phonenumber;
	
	@Pattern(regexp = "GOOGLE|APPLOGIN")
	@Column(name = "login_type")
	private String logintype;
	
	@Column(name= "imagepath")
	private String profileimagepath;
		
	@Column(nullable = false, updatable = false)
	private LocalDateTime createdat;
	

	private LocalDateTime updatedat;
	
	public User() {
		// TODO Auto-generated constructor stub
	}

	public User(@Email(message = "Invalid Format") String email, String password, String fullname, String phonenumber,
			@Pattern(regexp = "GOOGLE|APPLOGIN") String logintype, String profileimagepath) {
		super();
		this.email = email;
		this.password = password;
		this.fullname = fullname;
		this.phonenumber = phonenumber;
		this.logintype = logintype;
		this.profileimagepath= profileimagepath;
		this.createdat = LocalDateTime.now();
		this.updatedat = LocalDateTime.now();
	}

	public UUID getUserid() {
		return userid;
	}

	public void setUserid(UUID userid) {
		this.userid = userid;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getFullname() {
		return fullname;
	}

	public void setFullname(String fullname) {
		this.fullname = fullname;
	}

	public String getPhonenumber() {
		return phonenumber;
	}

	public void setPhonenumber(String phonenumber) {
		this.phonenumber = phonenumber;
	}

	public String getLogintype() {
		return logintype;
	}

	public void setLogintype(String logintype) {
		this.logintype = logintype;
	}

	public String getProfileimagepath() {
		return profileimagepath;
	}

	public void setProfileimagepath(String profileimagepath) {
		this.profileimagepath = profileimagepath;
	}

	public LocalDateTime getCreatedat() {
		return createdat;
	}

	public void setCreatedat(LocalDateTime createdat) {
		this.createdat = createdat;
	}

	public LocalDateTime getUpdatedat() {
		return updatedat;
	}

	public void setUpdatedat(LocalDateTime updatedat) {
		this.updatedat = updatedat;
	}
}
