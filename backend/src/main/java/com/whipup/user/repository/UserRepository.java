package com.whipup.user.repository;

import com.whipup.user.domain.User;
import java.time.OffsetDateTime;
import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface UserRepository extends JpaRepository<User, Long> {

	@Query("select u.id from User u where u.lastActiveAt < :cutoff")
	List<Long> findInactiveUserIds(@Param("cutoff") OffsetDateTime cutoff);
}
