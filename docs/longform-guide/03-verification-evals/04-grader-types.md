# Grader Types for Evaluation Systems

> **Different grading approaches for different verification scenarios**

## 개요 (Overview)

평가(Evaluation) 시스템의 핵심은 **자동화된 의사결정**입니다. Claude가 생성한 결과물의 품질을 판단하려면 **신뢰할 수 있는 평가자(Grader)**가 필요합니다.

Evaluation에서 사용할 수 있는 **3가지 주요 평가자 유형**이 있습니다:

1. **Code-Based Graders** - 객관적이고 빠른 판단
2. **Model-Based Graders** - 유연하고 뉘앙스 있는 판단
3. **Human Graders** - 최고의 품질 기준

각 유형은 **장단점이 다르므로**, 평가할 항목의 특성에 따라 **올바른 도구를 선택**해야 합니다.

---

## 1. Code-Based Graders (코드 기반 평가자)

### 1.1 개념 (Concept)

**Code-Based Grader**는 **명확한 규칙과 논리**를 사용하여 결과물을 평가하는 자동화된 평가 방식입니다.

**3가지 주요 기법:**

#### 1. String Match (문자열 매칭)
```python
# 정확한 일치 확인
expected = "The answer is 42"
actual = response.text
score = 1.0 if expected == actual else 0.0
```

**사용 사례:**
- 정해진 답변이 명확한 경우
- 프로그래밍 문제의 정확한 출력
- 특정 형식 확인

#### 2. Binary Tests (이진 테스트)
```python
# 특정 조건 충족 여부 확인
def grade_json_response(response):
    try:
        data = json.loads(response.text)
        return 1.0 if "required_field" in data else 0.0
    except json.JSONDecodeError:
        return 0.0
```

**사용 사례:**
- 유효한 JSON/XML 생성 확인
- 필수 필드 포함 확인
- 프로그램 실행 성공/실패

#### 3. Static Analysis (정적 분석)
```python
# 코드 구조와 패턴 분석
def grade_code_quality(code):
    issues = 0

    # Check for obvious bugs
    if "= =" in code:  # double equals typo
        issues += 1

    # Check for security issues
    if "eval(" in code:
        issues += 1

    # Check for code smells
    if len(code.split('\n')) > 200:
        issues += 1

    return 1.0 - (issues * 0.1)
```

**사용 사례:**
- 코드 품질 검사 (linting)
- 보안 취약점 탐지
- 성능 반안티패턴 감지

### 1.2 장점 (Advantages)

| 장점 | 설명 |
|------|------|
| **빠름 (Fast)** | 밀리초 단위로 평가 완료 |
| **저렴함 (Cheap)** | API 호출이나 인력 비용 없음 |
| **객관적 (Objective)** | 규칙 기반이므로 일관성 있음 |
| **재현 가능 (Deterministic)** | 같은 입력은 항상 같은 결과 |
| **명확한 근거 (Auditable)** | 왜 통과/실패했는지 정확히 알 수 있음 |

### 1.3 단점 (Disadvantages)

| 단점 | 설명 |
|------|------|
| **변형에 취약 (Brittle)** | 약간의 변화도 실패로 처리할 수 있음 |
| **제한된 판단 (Limited Scope)** | 명확한 규칙으로만 평가 가능 |
| **거짓 부정/긍정** | 올바른 답을 다르게 표현하면 탈락 |
| **경계 사례 어려움** | 명확하지 않은 상황에 대해 판단 불가 |

### 1.4 실제 예제 (Examples)

#### 예제 1: 계산 결과 검증
```python
class MathGrader:
    def grade(self, response: str, expected_answer: float) -> float:
        """
        수학 문제 답변을 평가합니다.

        정확한 숫자 추출 후 비교합니다.
        """
        import re

        # 숫자 추출
        numbers = re.findall(r'-?\d+\.?\d*', response)

        if not numbers:
            return 0.0

        try:
            actual = float(numbers[-1])  # 마지막 숫자

            # 오차 범위 내에서 통과
            tolerance = expected_answer * 0.01  # 1% 오차
            if abs(actual - expected_answer) <= tolerance:
                return 1.0
            return 0.0
        except (ValueError, IndexError):
            return 0.0

# 사용
grader = MathGrader()
response = "The answer is 42.5"
score = grader.grade(response, 42.5)  # 1.0
```

#### 예제 2: 코드 구문 검증
```python
class CodeGrader:
    def grade(self, code: str) -> float:
        """
        생성된 코드의 문법과 기본 품질을 검사합니다.
        """
        import ast

        try:
            # Python 구문 검증
            ast.parse(code)
            syntax_valid = True
        except SyntaxError:
            return 0.0

        score = 1.0

        # 코드 품질 점수 감소
        if "TODO" in code or "FIXME" in code:
            score -= 0.1

        if code.count('\n') > 300:  # 너무 긴 함수
            score -= 0.2

        return max(0.0, score)

# 사용
grader = CodeGrader()
score = grader.grade(python_code)
```

#### 예제 3: JSON 응답 검증
```python
class JSONGrader:
    def __init__(self, required_fields: list[str]):
        self.required_fields = required_fields

    def grade(self, response: str) -> float:
        """
        JSON 응답이 필수 필드를 포함하는지 검증합니다.
        """
        import json

        try:
            data = json.loads(response)
        except json.JSONDecodeError:
            return 0.0

        missing_fields = []
        for field in self.required_fields:
            if field not in data:
                missing_fields.append(field)

        # 각 누락된 필드마다 0.2점 감소
        score = 1.0 - (len(missing_fields) * 0.2)
        return max(0.0, score)

# 사용
grader = JSONGrader(["id", "name", "email", "timestamp"])
response = '{"id": 1, "name": "John", "email": "john@example.com", "timestamp": "2024-01-25"}'
score = grader.grade(response)  # 1.0
```

### 1.5 언제 사용할까? (When to Use)

**Code-Based Graders는 다음 상황에서 최선의 선택입니다:**

- ✅ 정해진 정답이 명확한 경우
- ✅ 객관적인 기준으로 판단 가능한 경우
- ✅ 성능과 비용이 중요한 경우
- ✅ 응답의 형식(format)을 검증해야 하는 경우
- ✅ 실시간 평가가 필요한 경우

**사용하면 안 되는 경우:**

- ❌ 여러 올바른 답변이 가능한 경우
- ❌ 창의성이나 품질 판단이 필요한 경우
- ❌ 뉘앙스 있는 평가가 필요한 경우

---

## 2. Model-Based Graders (모델 기반 평가자)

### 2.1 개념 (Concept)

**Model-Based Grader**는 **다른 AI 모델**(보통 Claude)을 사용하여 결과물을 평가하는 방식입니다.

**2가지 주요 방식:**

#### 1. Rubric Scoring (루브릭 평가)
```python
# 명확한 기준으로 점수 부여
rubric = """
채점 기준:
- 정확성 (0-10): 답변이 사실에 정확한가?
- 명확성 (0-10): 답변이 쉽게 이해되는가?
- 완결성 (0-10): 모든 측면을 다루었는가?

총점 = (정확성 + 명확성 + 완결성) / 3
"""

response = """
질문: Python에서 list와 tuple의 차이는?

평가:
- 정확성 (9/10): 주요 차이점을 정확히 설명했으나, 메모리 사용 차이 언급 부족
- 명확성 (10/10): 매우 명확한 예제와 함께 설명
- 완결성 (8/10): 기본 차이점은 모두 다루었으나 성능 측면 미흡

총점: 9/10
"""
```

#### 2. Natural Language Assertions (자연어 주장)
```python
# 자연어로 평가 기준을 작성
evaluation_prompt = """
다음 코드가 안전한지 평가하세요:
- SQL Injection 가능성 확인
- 권한 검증 확인
- 에러 처리 확인

안전하면 "PASS", 위험하면 "FAIL" 이유와 함께 답변하세요.
"""
```

### 2.2 모델 기반 평가의 종류

#### Type A: Self-Grading (자기평가)
```python
def self_grade(task: str, response: str) -> float:
    """
    Claude가 자신의 답변을 평가합니다.
    """
    prompt = f"""
    Task: {task}
    Your response: {response}

    Rate your response on a scale of 0-100. Be critical and honest.
    Explain your rating.

    Return JSON: {{"score": <0-100>, "explanation": "<reason>"}}
    """

    evaluation = call_claude(prompt)
    return parse_score(evaluation)
```

**장점:**
- 빠름 (같은 모델이므로 컨텍스트 재사용 가능)
- 자신의 생각 과정을 이해

**단점:**
- 편향될 수 있음 (자신의 답변에 관대할 수 있음)

#### Type B: Cross-Evaluation (교차평가)
```python
def cross_grade(task: str, response: str) -> float:
    """
    다른 모델이 평가합니다.
    """
    prompt = f"""
    Evaluate this response to the task:

    Task: {task}
    Response: {response}

    Score: 0-100
    Criteria:
    1. Correctness (정확성)
    2. Clarity (명확성)
    3. Completeness (완결성)
    4. Safety (안전성)

    Provide detailed feedback and a final score.
    """

    evaluation = call_claude(prompt)
    return parse_score(evaluation)
```

**장점:**
- 더 객관적인 평가
- 편향 감소

**단점:**
- 느림 (별도 API 호출)
- 비쌈 (추가 토큰 사용)

#### Type C: Ensemble Grading (앙상블 평가)
```python
def ensemble_grade(task: str, response: str) -> float:
    """
    여러 평가자의 의견을 종합합니다.
    """
    graders = [
        claude_opus,  # 정확성 전문가
        claude_sonnet,  # 명확성 전문가
        claude_haiku  # 빠른 평가
    ]

    scores = []
    for grader in graders:
        score = grader.evaluate(task, response)
        scores.append(score)

    # 평균 점수 반환
    return sum(scores) / len(scores)
```

**장점:**
- 가장 신뢰할 수 있는 결과
- 다양한 관점 포함

**단점:**
- 느림 (N배 더 많은 호출)
- 비쌈 (N배 비용)

### 2.3 실제 예제 (Examples)

#### 예제 1: 루브릭 기반 평가
```python
class RubricGrader:
    def __init__(self, model):
        self.model = model

    def grade(self, task: str, response: str, rubric: dict) -> dict:
        """
        루브릭을 사용하여 응답을 평가합니다.

        Args:
            task: 평가할 작업 설명
            response: 평가할 응답
            rubric: {기준: (최대점수, 설명)}

        Returns:
            {기준: 점수, 'total': 총점, 'explanation': 설명}
        """
        rubric_text = "\n".join([
            f"- {criterion} ({max_points} points): {description}"
            for criterion, (max_points, description) in rubric.items()
        ])

        prompt = f"""
You are an expert evaluator. Grade the following response using the rubric below.

Task: {task}

Response:
{response}

Rubric:
{rubric_text}

Provide:
1. Score for each criterion (0 to max points)
2. Total score (sum of all criteria)
3. Brief explanation for each score

Return as JSON:
{{
    "scores": {{"<criterion>": <score>, ...}},
    "total": <total>,
    "explanations": {{"<criterion>": "<explanation>", ...}}
}}
"""

        result = self.model.evaluate(prompt)
        return json.loads(result)

# 사용
rubric = {
    "Correctness": (40, "Does the response answer the question accurately?"),
    "Clarity": (30, "Is the response clear and well-organized?"),
    "Completeness": (20, "Does the response cover all relevant aspects?"),
    "Relevance": (10, "Is all information relevant to the task?")
}

grader = RubricGrader(claude)
scores = grader.grade(task, response, rubric)
print(f"Total Score: {scores['total']}/100")
```

#### 예제 2: 자동 피드백 생성
```python
class FeedbackGrader:
    def __init__(self, model):
        self.model = model

    def grade(self, code: str, requirements: str) -> dict:
        """
        코드를 평가하고 개선 피드백을 생성합니다.
        """
        prompt = f"""
Review the following code against the requirements:

Requirements:
{requirements}

Code:
{code}

Evaluate:
1. Does it meet all requirements? (YES/NO)
2. Code quality issues (list)
3. Potential bugs (list)
4. Performance concerns (list)
5. Security issues (list)
6. Suggestions for improvement (list)

Rate overall: EXCELLENT / GOOD / FAIR / POOR

Provide constructive feedback.
"""

        evaluation = self.model.evaluate(prompt)

        return {
            "evaluation": evaluation,
            "pass": "YES" in evaluation and "EXCELLENT" in evaluation,
            "score": self._calculate_score(evaluation)
        }

    def _calculate_score(self, evaluation: str) -> float:
        """평가 텍스트에서 점수 추출"""
        if "EXCELLENT" in evaluation:
            return 1.0
        elif "GOOD" in evaluation:
            return 0.8
        elif "FAIR" in evaluation:
            return 0.6
        else:
            return 0.4

# 사용
grader = FeedbackGrader(claude)
result = grader.grade(python_code, requirements)
if result['pass']:
    print("Code review passed!")
else:
    print("Code needs improvements:")
    print(result['evaluation'])
```

#### 예제 3: 지정된 기준으로 평가
```python
class CriterionBasedGrader:
    def __init__(self, model):
        self.model = model

    def grade(self, content: str, criteria: list[str]) -> dict:
        """
        명확한 기준 목록으로 평가합니다.

        각 기준을 YES/NO로 평가하여 합격/불합격 결정.
        """
        criteria_text = "\n".join([
            f"- Criterion {i+1}: {criterion}"
            for i, criterion in enumerate(criteria)
        ])

        prompt = f"""
Evaluate the following content against these criteria:

{criteria_text}

Content to evaluate:
{content}

For each criterion:
1. State clearly if it's met (YES/NO)
2. Provide evidence or explanation

Format as JSON:
{{
    "criteria_met": {{"criterion_1": true/false, ...}},
    "passed": true/false,  # All criteria must be met
    "evidence": {{"criterion_1": "<evidence>", ...}}
}}
"""

        result = self.model.evaluate(prompt)
        return json.loads(result)

# 사용
criteria = [
    "Response addresses the main question",
    "Response includes specific examples",
    "Response is free from grammatical errors",
    "Response avoids speculation without evidence"
]

grader = CriterionBasedGrader(claude)
result = grader.grade(response_text, criteria)

if result['passed']:
    print("Response meets all criteria!")
else:
    print("Response failed these criteria:")
    for criterion, met in result['criteria_met'].items():
        if not met:
            print(f"- {criterion}")
            print(f"  Evidence: {result['evidence'][criterion]}")
```

### 2.4 장점 (Advantages)

| 장점 | 설명 |
|------|------|
| **유연함 (Flexible)** | 복잡한 판단과 뉘앙스 이해 가능 |
| **뉘앙스 처리** | 같은 의미의 다양한 표현 인식 |
| **자연스러운 평가** | 인간처럼 맥락을 고려한 평가 |
| **피드백 생성** | 단순 점수뿐 아니라 이유와 개선안 제시 |
| **확장 가능** | 새로운 기준을 쉽게 추가 가능 |

### 2.5 단점 (Disadvantages)

| 단점 | 설명 |
|------|------|
| **비결정적 (Non-deterministic)** | 같은 입력도 다른 결과 가능 |
| **느림 (Slow)** | API 호출로 인해 지연 발생 |
| **비쌈 (Expensive)** | 추가 토큰 사용으로 비용 증가 |
| **편향 가능** | 프롬프트 변화에 따라 결과 변함 |
| **감사 어려움** | 왜 이 점수인지 설명이 불완전할 수 있음 |

### 2.6 언제 사용할까? (When to Use)

**Model-Based Graders는 다음 상황에서 최적입니다:**

- ✅ 여러 올바른 답변이 가능한 경우
- ✅ 품질과 창의성을 평가해야 하는 경우
- ✅ 맥락과 뉘앙스를 이해해야 하는 경우
- ✅ 상세한 피드백이 필요한 경우
- ✅ 비용이 주요 제약이 아닌 경우

**사용하면 안 되는 경우:**

- ❌ 대량의 평가가 필요한 경우 (비용 문제)
- ❌ 실시간 응답이 필요한 경우 (속도 문제)
- ❌ 완벽한 일관성이 필요한 경우

---

## 3. Human Graders (인간 평가자)

### 3.1 개념 (Concept)

**Human Grader**는 **전문 인력**이 직접 결과물을 평가하는 방식입니다.

**3가지 주요 유형:**

#### 1. SME Review (Subject Matter Expert)
```
고급 개발자가 코드 품질을 평가
데이터 과학자가 모델 성능을 평가
도메인 전문가가 정확성을 평가
```

**장점:**
- 가장 정확한 평가
- 숨겨진 문제 발견 가능
- 맥락 이해

**단점:**
- 가장 비쌈
- 가장 느림
- 개인차 존재

#### 2. Crowdsourced Judgment (크라우드 평가)
```
여러 일반인의 의견을 종합
다수결로 결정
비용 절감 가능
```

**장점:**
- 비교적 저렴
- 다양한 관점
- 확장 가능

**단점:**
- 낮은 전문성
- 품질 편차
- 의견 불일치 가능

#### 3. Hybrid Approach (하이브리드)
```
먼저 자동화 평가 실시
불확실한 경우만 인간 평가 요청
필수적인 경우만 SME 검토
```

**장점:**
- 비용과 정확성 균형
- 핵심에만 집중
- 효율적

**단점:**
- 복잡한 구현
- 임계값 설정 필요

### 3.2 구현 예제 (Examples)

#### 예제 1: SME 검토 프로세스
```python
class SMEReviewGrader:
    def __init__(self, sme_pool: list[str]):
        """
        전문가 풀을 초기화합니다.
        """
        self.sme_pool = sme_pool  # 전문가 이메일 목록
        self.reviews = {}

    def request_review(self, task_id: str, content: str) -> dict:
        """
        전문가에게 리뷰를 요청합니다.
        """
        review_request = {
            "task_id": task_id,
            "content": content,
            "requested_at": datetime.now(),
            "assigned_to": self.sme_pool[0],  # 첫 번째 전문가에 할당
            "status": "PENDING"
        }

        # 이메일 발송
        send_email(
            to=review_request['assigned_to'],
            subject=f"Review Request: {task_id}",
            body=self._format_review_request(review_request)
        )

        self.reviews[task_id] = review_request
        return review_request

    def submit_review(self, task_id: str, score: int, comments: str) -> dict:
        """
        전문가가 검토 결과를 제출합니다.
        """
        self.reviews[task_id].update({
            "score": score,  # 0-100
            "comments": comments,
            "reviewed_at": datetime.now(),
            "status": "COMPLETED"
        })

        return self.reviews[task_id]

    def get_final_score(self, task_id: str) -> float:
        """최종 점수를 반환합니다."""
        if task_id not in self.reviews:
            return None

        review = self.reviews[task_id]
        if review['status'] == 'COMPLETED':
            return review['score'] / 100.0
        return None

# 사용
sme_list = [
    "senior-dev-1@company.com",
    "senior-dev-2@company.com",
    "architect@company.com"
]

grader = SMEReviewGrader(sme_list)

# 리뷰 요청
review_req = grader.request_review("task-123", code_content)

# 나중에 전문가가 결과 제출
grader.submit_review("task-123", score=92, comments="Great code quality!")

# 최종 점수 확인
final_score = grader.get_final_score("task-123")  # 0.92
```

#### 예제 2: 크라우드 평가
```python
class CrowdsourcedGrader:
    def __init__(self, min_reviewers: int = 3):
        """
        크라우드 평가를 설정합니다.
        """
        self.min_reviewers = min_reviewers
        self.reviews = {}

    def create_task(self, task_id: str, content: str,
                   criteria: list[str]) -> dict:
        """
        평가 작업을 생성합니다.
        """
        return {
            "task_id": task_id,
            "content": content,
            "criteria": criteria,
            "reviews": [],
            "status": "OPEN"
        }

    def submit_review(self, task_id: str, reviewer_id: str,
                     scores: dict, comments: str) -> dict:
        """
        리뷰어가 평가를 제출합니다.

        Args:
            task_id: 평가할 작업 ID
            reviewer_id: 리뷰어의 고유 ID
            scores: {기준: (0-5)} 형태의 점수
            comments: 의견
        """
        review = {
            "reviewer_id": reviewer_id,
            "scores": scores,
            "comments": comments,
            "submitted_at": datetime.now()
        }

        self.reviews[task_id] = self.reviews.get(task_id, [])
        self.reviews[task_id].append(review)

        # 최소 리뷰어 수에 도달했으면 결과 계산
        if len(self.reviews[task_id]) >= self.min_reviewers:
            return self._calculate_final_score(task_id)

        return review

    def _calculate_final_score(self, task_id: str) -> dict:
        """
        모든 리뷰의 평균을 계산합니다.
        """
        reviews = self.reviews[task_id]

        # 각 기준별 점수 평균 계산
        criteria_scores = {}
        for criterion in reviews[0]['scores'].keys():
            scores = [r['scores'][criterion] for r in reviews]
            criteria_scores[criterion] = sum(scores) / len(scores)

        # 전체 평균 (0-5를 0-1로 정규화)
        overall_score = sum(criteria_scores.values()) / len(criteria_scores)

        return {
            "task_id": task_id,
            "reviewer_count": len(reviews),
            "criteria_scores": criteria_scores,
            "overall_score": overall_score / 5.0,
            "status": "COMPLETED"
        }

# 사용
grader = CrowdsourcedGrader(min_reviewers=3)

# 평가 작업 생성
task = grader.create_task(
    "task-456",
    content=response_text,
    criteria=["Accuracy", "Clarity", "Completeness"]
)

# 여러 리뷰어의 평가 수집
grader.submit_review("task-456", "reviewer-001",
                    {"Accuracy": 5, "Clarity": 4, "Completeness": 5},
                    "Great response!")

grader.submit_review("task-456", "reviewer-002",
                    {"Accuracy": 4, "Clarity": 5, "Completeness": 4},
                    "Mostly good, minor issues")

result = grader.submit_review("task-456", "reviewer-003",
                             {"Accuracy": 5, "Clarity": 5, "Completeness": 5},
                             "Perfect!")

print(f"Final Score: {result['overall_score']:.2f}")
# Output: Final Score: 0.93
```

#### 예제 3: 하이브리드 평가 (자동 + 인간)
```python
class HybridGrader:
    def __init__(self, auto_grader, human_grader, confidence_threshold=0.8):
        """
        자동 평가와 인간 평가를 조합합니다.

        Args:
            auto_grader: 자동 평가 도구
            human_grader: 인간 평가 도구
            confidence_threshold: 자동 평가 신뢰도 임계값
        """
        self.auto_grader = auto_grader
        self.human_grader = human_grader
        self.confidence_threshold = confidence_threshold

    def grade(self, task: str, content: str) -> dict:
        """
        하이브리드 평가를 수행합니다.

        1. 먼저 자동 평가 실시
        2. 신뢰도가 낮으면 인간 평가 요청
        3. 최종 점수 반환
        """
        # Step 1: 자동 평가
        auto_result = self.auto_grader.grade(task, content)

        # Step 2: 신뢰도 확인
        if auto_result.get('confidence', 0) >= self.confidence_threshold:
            # 신뢰도 높음 - 자동 평가 사용
            return {
                "score": auto_result['score'],
                "method": "AUTOMATED",
                "confidence": auto_result['confidence']
            }

        # Step 3: 신뢰도 낮음 - 인간 평가 요청
        print(f"Confidence too low ({auto_result['confidence']:.0%}), "
              "requesting human review...")

        human_result = self.human_grader.request_review(task, content)

        return {
            "score": human_result['score'],
            "method": "HUMAN",
            "human_reviewer": human_result['reviewed_by'],
            "auto_score": auto_result['score'],
            "confidence": 1.0  # 인간 평가는 최고 신뢰도
        }

# 사용
hybrid_grader = HybridGrader(
    auto_grader=ModelBasedGrader(),
    human_grader=SMEReviewGrader(sme_list),
    confidence_threshold=0.85
)

result = hybrid_grader.grade(task, response)

if result['method'] == 'AUTOMATED':
    print(f"✓ Automated evaluation: {result['score']:.2f}")
else:
    print(f"✓ Human review by {result['human_reviewer']}: {result['score']:.2f}")
    print(f"  (Auto score was {result['auto_score']:.2f})")
```

### 3.3 장점 (Advantages)

| 장점 | 설명 |
|------|------|
| **최고 품질 (Gold Standard)** | 가장 정확한 평가 가능 |
| **문제 발견** | 자동화가 놓칠 수 있는 문제 발견 |
| **맥락 이해** | 전체 상황을 종합적으로 판단 |
| **유연한 판단** | 경계 사례와 예외 상황 처리 |
| **신뢰성** | 최종 검증이 필요한 경우 최적 |

### 3.4 단점 (Disadvantages)

| 단점 | 설명 |
|------|------|
| **매우 비쌈 (Very Expensive)** | SME 비용이 매우 높음 |
| **매우 느림 (Very Slow)** | 수동 검토에 시간 소요 |
| **확장 불가 (Not Scalable)** | 대량 평가 불가능 |
| **개인차 (Variability)** | 평가자에 따라 결과 다름 |
| **병목 현상 (Bottleneck)** | 평가 대기 시간 발생 |

### 3.5 언제 사용할까? (When to Use)

**Human Graders는 다음 상황에서만 권장합니다:**

- ✅ 최종 품질 보증(QA)이 필수인 경우
- ✅ 높은 위험도 작업 (의료, 법률 등)
- ✅ 자동화 평가가 불가능한 경우
- ✅ 새로운 도메인에서 평가 기준 수립
- ✅ 매우 중요한 결정 검증

**사용하면 안 되는 경우:**

- ❌ 대량의 일상적 평가
- ❌ 실시간 응답이 필요한 경우
- ❌ 비용이 제약인 경우

---

## 4. 비교 및 선택 가이드 (Comparison & Selection Guide)

### 4.1 종합 비교표 (Comprehensive Comparison)

| 기준 | Code-Based | Model-Based | Human |
|------|-----------|------------|-------|
| **속도** | ⚡⚡⚡ 매우 빠름 | ⚡ 느림 | 🐌 매우 느림 |
| **비용** | 💰 거의 무료 | 💰💰 중간 | 💰💰💰 매우 비쌈 |
| **정확성** | ⭐⭐ 제한적 | ⭐⭐⭐ 높음 | ⭐⭐⭐⭐⭐ 최고 |
| **일관성** | ✅ 100% 일관 | ⚠️ 약간 변함 | ⚠️⚠️ 큰 편차 |
| **유연성** | ❌ 매우 낮음 | ✅ 높음 | ✅ 매우 높음 |
| **확장성** | ✅ 무제한 | ⚠️ 제한적 | ❌ 매우 제한 |
| **뉘앙스** | ❌ 처리 불가 | ✅ 이해 가능 | ✅✅ 깊이 있게 |
| **감사** | ✅ 투명함 | ⚠️ 설명 가능 | ✅ 명확함 |

### 4.2 작업 유형별 추천 (Recommendations by Task Type)

#### 📝 문서/에세이 평가
```
1차: Model-Based (루브릭 평가)
2차: Human (필요시 SME 검토)

왜: 문법, 명확성, 완결성 등 뉘앙스 필요
```

#### 💻 코드 품질 평가
```
1차: Code-Based (구문 검증, linting)
2차: Model-Based (구조, 패턴 분석)
3차: Human (SME 코드 리뷰 - 선택)

왜: 객관적 기준부터 시작, 필요시 심화
```

#### 🔢 계산 결과 검증
```
1차: Code-Based (수치 비교)

왜: 정확한 답이 명확함, 빠르고 저렴함
```

#### 📚 창의성 평가
```
1차: Model-Based (자연어 평가)
2차: Human (최종 심사 - 필요시)

왜: 창의성은 다양한 관점 필요
```

#### 🛡️ 보안/안전성 평가
```
1차: Code-Based (취약점 스캔)
2차: Model-Based (로직 분석)
3차: Human (침투 테스트 - 필수)

왜: 안전은 여러 계층의 검증 필요
```

### 4.3 파이프라인 설계 (Pipeline Design)

#### 예제: 다단계 평가 파이프라인
```python
class EvaluationPipeline:
    def __init__(self):
        self.code_grader = CodeBasedGrader()
        self.model_grader = ModelBasedGrader()
        self.human_grader = SMEReviewGrader(sme_list)

    def evaluate(self, task: str, response: str,
                risk_level: str = "medium") -> dict:
        """
        위험도에 따라 평가 단계를 결정합니다.

        Args:
            task: 평가 작업 설명
            response: 평가할 응답
            risk_level: "low" / "medium" / "high"

        Returns:
            {score, method, details}
        """

        # Step 1: 기본 검증 (항상 수행)
        code_result = self.code_grader.grade(response)

        if code_result['score'] < 0.5:
            # 기본 요구사항 불만족 - 즉시 불합격
            return {
                "passed": False,
                "score": 0.0,
                "reason": "Failed basic validation",
                "details": code_result
            }

        # Step 2: 모델 평가 (위험도 medium 이상)
        if risk_level in ["medium", "high"]:
            model_result = self.model_grader.grade(task, response)

            if model_result['score'] < 0.7 and risk_level == "high":
                # 높은 위험도 + 낮은 점수 - 인간 검토 요청
                human_result = self.human_grader.request_review(
                    task, response
                )
                return {
                    "passed": human_result['score'] >= 0.7,
                    "score": human_result['score'],
                    "method": "HUMAN_REVIEW",
                    "details": {
                        "code_score": code_result['score'],
                        "model_score": model_result['score'],
                        "human_score": human_result['score']
                    }
                }

            return {
                "passed": model_result['score'] >= 0.7,
                "score": model_result['score'],
                "method": "MODEL_BASED" if risk_level == "medium" else "MULTI_STAGE",
                "details": model_result
            }

        # Step 3: 낮은 위험도는 코드 검증만
        return {
            "passed": code_result['score'] >= 0.8,
            "score": code_result['score'],
            "method": "CODE_BASED",
            "details": code_result
        }

# 사용
pipeline = EvaluationPipeline()

# 낮은 위험도 작업
result = pipeline.evaluate(
    task="Format response as JSON",
    response='{"status": "ok"}',
    risk_level="low"
)
print(f"Score: {result['score']}")  # 빠르게 평가됨

# 높은 위험도 작업
result = pipeline.evaluate(
    task="Write secure database code",
    response=database_code,
    risk_level="high"
)
# 필요시 인간 검토까지 진행
```

### 4.4 비용-품질 트레이드오프 (Cost-Quality Tradeoff)

```
품질 (Quality)
     │
   100│ ╔════════════ Human (최고 품질, 최고 비용)
     │ ║
     │ ║    ╔═══════ Model-Based (중간, 중간 비용)
     │ ║    ║
   50│ ║    ║    ╔═ Code-Based (낮음, 거의 무료)
     │ ║    ║    ║
     │ └────┴────┴──────────────→ 비용 (Cost)
     └─────────────────────────────────
```

**최적 전략:**

1. **대량 평가** → Code-Based (저비용, 빠름)
2. **품질 향상** → Model-Based 추가
3. **위험 최소화** → Human 검토 추가

---

## 5. 실제 적용 (Practical Implementation)

### 5.1 평가자 선택 의사결정 트리

```
평가가 필요한가?
├─ NO → 평가 불필요
└─ YES
   ├─ 정답이 명확한가?
   │  ├─ YES
   │  │  ├─ 형식 검증만 필요?
   │  │  │  ├─ YES → Code-Based Grader
   │  │  │  └─ NO → Code-Based + Model-Based
   │  │  └─ 대량 평가?
   │  │     ├─ YES → Code-Based
   │  │     └─ NO → Model-Based
   │  └─ NO
   │     ├─ 위험도가 높은가?
   │     │  ├─ YES → Human Grader (필수)
   │     │  └─ NO
   │     │     ├─ 예산이 충분한가?
   │     │     │  ├─ YES → Model-Based + Human
   │     │     │  └─ NO → Model-Based
   │     │     └─ 시간이 충분한가?
   │     │        ├─ YES → 더 신뢰할 수 있는 평가
   │     │        └─ NO → Model-Based로 빠르게
```

### 5.2 평가 시스템 구현 체크리스트

```python
# 1. 평가 기준 정의
criteria = {
    "Correctness": {
        "weight": 0.4,
        "grader_type": "code_based",
        "threshold": 0.9
    },
    "Clarity": {
        "weight": 0.3,
        "grader_type": "model_based",
        "threshold": 0.7
    },
    "Completeness": {
        "weight": 0.3,
        "grader_type": "model_based",
        "threshold": 0.8
    }
}

# 2. 평가자 초기화
graders = {
    "code_based": CodeBasedGrader(),
    "model_based": ModelBasedGrader(),
    "human": SMEReviewGrader(sme_list)
}

# 3. 평가 실행
def evaluate_response(task, response, criteria, graders):
    scores = {}
    weighted_sum = 0

    for criterion, config in criteria.items():
        grader = graders[config['grader_type']]
        score = grader.grade(task, response)

        if score < config['threshold']:
            print(f"⚠️ {criterion} below threshold")

        scores[criterion] = score
        weighted_sum += score * config['weight']

    return {
        "scores": scores,
        "overall": weighted_sum,
        "passed": weighted_sum >= 0.8
    }

# 4. 결과 보고
result = evaluate_response(task, response, criteria, graders)
print(f"Final Score: {result['overall']:.2f}")
```

---

## 6. 모범 사례 (Best Practices)

### ✅ DO (해야 할 것)

1. **올바른 도구 선택**
   - 명확한 정답 → Code-Based
   - 뉘앙스 필요 → Model-Based
   - 고위험 → Human

2. **다단계 평가**
   - 빠른 필터링 (Code-Based)
   - 깊이 있는 평가 (Model-Based)
   - 최종 검증 (Human - 필요시)

3. **평가자 검증**
   - 평가자의 정확성 측정
   - 일관성 확인
   - 정기적 재교육

4. **결과 추적**
   - 모든 평가 기록
   - 성능 메트릭 수집
   - 개선점 도출

### ❌ DON'T (하면 안 될 것)

1. **한 가지 평가자만 사용**
   - 모든 상황에 적합한 평가자는 없음
   - 여러 관점에서 검증 필요

2. **과도한 자동화**
   - 모든 것을 자동화하면 위험
   - 중요한 부분은 인간 검토 필요

3. **비용 절감만 추구**
   - 저렴하지만 부정확한 평가는 더 비쌈
   - 품질과 비용의 균형 필요

4. **기준 없는 평가**
   - 명확한 기준 없으면 일관성 없음
   - 사전에 루브릭 작성 필수

---

## 7. 관련 리소스 (Resources)

### Anthropic 공식 가이드
- [Anthropic Evaluations Guide](https://docs.anthropic.com/en/docs/build-a-system/evals)
- [Evaluation Best Practices](https://docs.anthropic.com/en/docs/build-a-system/evals/best-practices)

### 추가 학습
- [ML Evaluation Metrics](https://github.com/anthropics/anthropic-sdk-python)
- [Rubric Design Patterns](https://en.wikipedia.org/wiki/Rubric_(academic))

---

## 8. 요약 (Summary)

| 평가자 유형 | 최고의 경우 | 피해야 할 경우 |
|-----------|----------|------------|
| **Code-Based** | 명확한 정답, 대량 평가 | 뉘앙스 필요, 창의성 평가 |
| **Model-Based** | 품질 판단, 피드백 필요 | 대량 평가, 실시간 필요 |
| **Human** | 고위험 결정, 최종 검증 | 일상적 평가, 비용 제약 |

**핵심 원칙:**

1. **작업의 특성에 맞게** 평가자를 선택하세요
2. **다단계 평가**로 비용과 품질을 균형 맞추세요
3. **평가 기준을 사전에** 명확히 정의하세요
4. **결과를 추적**하고 지속적으로 개선하세요

---

<div align="center">

### 올바른 평가자로 신뢰할 수 있는 시스템을 구축하세요.

</div>
