package com.skycom.test.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import com.skycom.test.repository.PostRepository;
import com.skycom.test.domain.Post;

@Service
public class PostService {

    @Autowired
    private PostRepository postRepository;

    public List<String> gendersTypeSelector() {
        return postRepository.findGendersType();
    }

    public List<String> locationsTypeSelector() {
        return postRepository.findLocationsType();
    }

    public int postsLength(Long id, String gender, int minAge, int maxAge, String location) {
        return postRepository.findPostsLength(id, gender, minAge, maxAge, location);
    }

    public List<Post> postSelector(Long id, int page, String gender, int minAge, int maxAge, String location) {
        int start = page * 10 - 10;

        return postRepository.findPosts(start, id, gender, minAge, maxAge, location);
    }

    public void insertPost(String gender, int age, String location) {
        postRepository.insertPost(gender, age, location);
    }

    public void updatePost(Long id, String gender, int age, String location) {
        postRepository.updateById(id, gender, age, location);
    }

    public void deletePost(Long id) {
        postRepository.deleteById(id);
    }

    public List<Post> downloadPost() {
        return postRepository.findAll();
    }
}
