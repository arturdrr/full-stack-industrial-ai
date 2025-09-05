import asyncio
from typing import Dict, Any, List
from datetime import datetime

class SmartContextManager:
    def __init__(self):
        self.max_context_tokens = 8000  # Limite seguro
        self.context_compression_ratio = 0.7
        
    async def manage_context(self, query: str, history: List, context: Dict) -> Dict:
        """Gerencia contexto de forma inteligente para evitar alucinações"""
        
        # 1. CALCULAR TOKENS ATUAIS
        current_tokens = self._count_tokens(query + str(history) + str(context))
        
        # 2. COMPRIMIR SE NECESSÁRIO  
        if current_tokens > self.max_context_tokens:
            context = await self._compress_context(context, history)
        
        # 3. ADICIONAR TERMINATORS EXPLÍCITOS
        context["termination_signals"] = [
            "TASK_COMPLETED",
            "NO_FURTHER_PROCESSING_NEEDED", 
            "ROUTING_FINAL_DECISION"
        ]
        
        # 4. ADICIONAR ANTI-LOOP INSTRUCTIONS
        context["anti_loop_instructions"] = """
        IMPORTANT SAFETY RULES:
        - If you've seen this exact query before in this session, respond with "DUPLICATE_QUERY_DETECTED"
        - If the conversation is going in circles, respond with "LOOP_DETECTED - TERMINATING"  
        - Always provide a definitive answer, avoid asking follow-up questions
        - Use TASK_COMPLETED when the request is fully handled
        """
        
        return context
    
    async def _compress_context(self, context: Dict, history: List) -> Dict:
        """Comprime contexto mantendo informações essenciais"""
        
        # Manter apenas últimas N interações
        if len(history) > 10:
            context["compressed_history"] = history[-5:]
            context["history_note"] = f"Compressed from {len(history)} interactions"
        
        # Remover metadados desnecessários
        essential_keys = ["user_id", "session_id", "current_task", "routing_decision"]
        context = {k: v for k, v in context.items() if k in essential_keys}
        
        return context
