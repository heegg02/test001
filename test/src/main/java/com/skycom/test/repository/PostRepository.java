package com.skycom.test.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.lang.NonNull;

import com.skycom.test.domain.Post;

import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {
    @Query("SELECT p.gender FROM Post p GROUP BY p.gender")
    List<String> gendersType();
       
    @Query("SELECT p.location FROM Post p GROUP BY p.location")
    List<String> locationsType();

    @Query("SELECT p FROM Post p WHERE " +
           "(:gender = '' OR p.gender = :gender) AND " +
           "(:minAge = 0 OR p.age >= :minAge) AND " +
           "(:maxAge = 0 OR p.age <= :maxAge) AND " +
           "(:location = '' OR p.location = :location)")
    List<Post> findPosts(String gender, int minAge, int maxAge, String location);
    
    @Modifying
    @Transactional
    @Query("UPDATE Post p SET p.gender = :gender, p.age = :age, p.location = :location WHERE p.id=:id")
    void updateById(Long id, String gender, int age, String location);

    @Modifying
    @Transactional
    @Query("DELETE FROM Post p WHERE p.id=:id")
    void deleteById(@NonNull Long id);

}
