package com.skycom.test.repository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.skycom.test.domain.Post;

import java.util.List;

@Repository
public class PostRepository { 
    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private NamedParameterJdbcTemplate namedParameterJdbcTemplate;

    public List<String> findGendersType() {
        return jdbcTemplate.queryForList(
            "SELECT gender FROM post GROUP BY gender", 
            String.class
        );
    }

    public List<String> findLocationsType() {
        return jdbcTemplate.queryForList(
            "SELECT location FROM post GROUP BY location", 
            String.class
        );
    }
        
    public int findPostsLength(Long id, String gender, int minAge, int maxAge, String location){
        String sql = "SELECT COUNT(id) FROM post WHERE " +
            "(:id = 0 OR id = :id) AND " +
            "(:gender = '' OR gender = :gender) AND " +
            "(:minAge = 0 OR age >= :minAge) AND " +
            "(:maxAge = 0 OR age <= :maxAge) AND " +
            "(:location = '' OR location = :location)";

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("id", id)
            .addValue("gender", gender)
            .addValue("minAge", minAge)
            .addValue("maxAge", maxAge)
            .addValue("location", location);

        Integer count = namedParameterJdbcTemplate.queryForObject(sql, params, Integer.class);
        return (count != null) ? count : 0;
    }

    public List<Post> findPosts(int start, Long id, String gender, int minAge, int maxAge, String location) {
        String sql = "SELECT * FROM post WHERE " +
            "(:id = 0 OR id = :id) AND " +
            "(:gender = '' OR gender = :gender) AND " +
            "(:minAge = 0 OR age >= :minAge) AND " +
            "(:maxAge = 0 OR age <= :maxAge) AND " +
            "(:location = '' OR location = :location) " +
            "LIMIT :start, 10";

        MapSqlParameterSource params = new MapSqlParameterSource()
            .addValue("id", id)
            .addValue("gender", gender)
            .addValue("minAge", minAge)
            .addValue("maxAge", maxAge)
            .addValue("location", location)
            .addValue("start", start);

        return namedParameterJdbcTemplate.query(sql, params,
            (rs, rowNum) -> {
                Post post = new Post();
                post.setId(rs.getLong("id"));
                post.setGender(rs.getString("gender"));
                post.setAge(rs.getInt("age"));
                post.setLocation(rs.getString("location"));
                return post;
            }
        );
        
    }

    public void insertPost(String gender, int age, String location) {
        jdbcTemplate.update("INSERT INTO post (gender, age, location) VALUES (?, ?, ?)",
                            gender, age, location);
    }

    public void updateById(Long id, String gender, int age, String location) {
        jdbcTemplate.update("UPDATE post SET gender = ?, age = ?, location = ? WHERE id = ?",
                            gender, age, location, id);
    }

    public void deleteById(Long id) {
        jdbcTemplate.update("DELETE FROM post WHERE id = ?", id);   
    }
    
    public List<Post> findAll() {
        return jdbcTemplate.query(
            "SELECT * FROM post", 
            (rs, rowNum) -> {
                Post post = new Post();
                post.setId(rs.getLong("id"));
                post.setGender(rs.getString("gender"));
                post.setAge(rs.getInt("age"));
                post.setLocation(rs.getString("location"));
                return post;
            }
        );
    }
}
