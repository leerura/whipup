package com.whipup.common.security;

import com.whipup.user.domain.User;
import com.whipup.user.repository.UserRepository;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

@Component
public class TermsConsentFilter extends OncePerRequestFilter {

    private static final String TERMS_VERSION = "v1";
    private static final String PRIVACY_VERSION = "v1";
    private final UserRepository userRepository;

    public TermsConsentFilter(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Override
    protected void doFilterInternal(
        HttpServletRequest request,
        HttpServletResponse response,
        FilterChain filterChain
    ) throws ServletException, IOException {
        String path = request.getRequestURI();
        if (isExempt(request)) {
            filterChain.doFilter(request, response);
            return;
        }

        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof Jwt jwt) {
            try {
                Long userId = Long.valueOf(jwt.getSubject());
                User user = userRepository.findById(userId).orElse(null);
                if (user != null && user.requiresTermsConsent(TERMS_VERSION, PRIVACY_VERSION)) {
                    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                    response.setContentType("application/json");
                    response.getWriter().write(
                        "{\"code\":\"TERMS_CONSENT_REQUIRED\",\"message\":\"약관 동의가 필요합니다.\"}"
                    );
                    return;
                }
            } catch (NumberFormatException ignored) {
                // The resource server will handle an invalid JWT subject.
            }
        }
        filterChain.doFilter(request, response);
    }

    private boolean isExempt(HttpServletRequest request) {
        String path = request.getRequestURI();
        return path.equals("/health")
            || path.equals("/api/v1/auth/guest")
            || path.equals("/api/v1/me/terms-consent")
            || (path.equals("/api/v1/me") && ("GET".equalsIgnoreCase(request.getMethod())
                || "DELETE".equalsIgnoreCase(request.getMethod())));
    }
}
