package com.distributedchat.userservice.config;

import org.hibernate.exception.ConstraintViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import jakarta.persistence.NoResultException;
import jakarta.persistence.PersistenceException;

@RestControllerAdvice
public class GlobalExceptionHandler {

	@ExceptionHandler(PersistenceException.class)
	public ResponseEntity<String> handPersistence(PersistenceException e){
		return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
				.body("Registration error: "+ e.getMessage());
	}
	
	@ExceptionHandler(org.hibernate.exception.ConstraintViolationException.class)
	public ResponseEntity<String> handleConstraint(ConstraintViolationException ex) {
        return ResponseEntity.status(HttpStatus.CONFLICT)
                             .body("Email already exists");
    }
	
	@ExceptionHandler({jakarta.persistence.NoResultException.class, org.springframework.dao.EmptyResultDataAccessException.class})
	public ResponseEntity<String> handleResult(NoResultException ex){
		return ResponseEntity.status(HttpStatus.NOT_FOUND)
				.body("Invalid Parameters");
	}

    @ExceptionHandler(Exception.class)
    public ResponseEntity<String> handleGeneric(Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                             .body("Unexpected error occurred");
    }
}
