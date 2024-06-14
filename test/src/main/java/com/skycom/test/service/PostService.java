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
        return postRepository.gendersType();
    }

    public List<String> locationsTypeSelector() {
        return postRepository.locationsType();
    }

    public List<Post> postSelector(String gender, int minAge, int maxAge, String location) {
        return postRepository.findPosts(gender, minAge, maxAge, location);
    }

    public void updatePost(Long id, String gender, int age, String location) {
        postRepository.updateById(id, gender, age, location);
    }

    public void deletePost(Long id) {
        postRepository.deleteById(id);
    }


}
