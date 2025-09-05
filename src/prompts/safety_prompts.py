class SafetyPrompts:
    @staticmethod
    def get_routing_classifier_prompt(query: str, context: Dict) -> str:
        """Prompt otimizado para classificação sem ambiguidade"""
        
        return f"""
You are a ROUTING CLASSIFIER. Your ONLY job is to classify queries for optimal routing.

CRITICAL RULES:
1. Respond with ONLY a valid JSON object
2. Do NOT execute the task, just classify it
3. Do NOT ask questions or provide explanations beyond classification
4. If unsure, default to "simple" category

Query to classify: "{query}"

Respond with EXACTLY this format:
{{
    "category": "simple|medium|complex|critical",
    "domain": "code|analysis|conversation|other", 
    "privacy": "public|private",
    "confidence": 0.85,
    "reasoning": "brief single sentence"
}}

JSON Response:"""
    
    @staticmethod  
    def get_agent_execution_prompt(task: str, context: Dict) -> str:
        """Prompt seguro para execução de agentes"""
        
        return f"""
TASK: {task}

SAFETY INSTRUCTIONS:
- Execute this task ONCE and provide final answer
- Use "TASK_COMPLETED" when finished
- Do NOT ask follow-up questions unless absolutely critical
- Do NOT repeat previous responses
- If task is unclear, ask ONE clarifying question then proceed

Session Context: {context.get('session_summary', 'New session')}

Your Response:"""
