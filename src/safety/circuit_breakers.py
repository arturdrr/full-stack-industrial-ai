import asyncio
from typing import Dict, Any, List
from datetime import datetime
import numpy as np

class SafetyController:
    def __init__(self):
        self.call_history = {}
        self.circuit_breakers = {
            "max_steps_per_agent": 10,
            "max_routing_depth": 5,
            "max_context_length": 50000,
            "max_cost_per_session": 2.00,
            "timeout_seconds": 30
        }
    
    async def safe_execute(self, agent_func, context):
        """Execução segura com múltiplos safeguards"""
        
        session_id = context.get("session_id")
        
        # 1. VERIFICAR HISTÓRICO DE CALLS
        if self._detect_loop(session_id):
            raise LoopDetectedException("Loop detectado - interrompendo execução")
        
        # 2. VERIFICAR LIMITES
        if self._check_limits_exceeded(session_id):
            raise LimitsExceededException("Limites de segurança excedidos")
        
        # 3. EXECUTAR COM TIMEOUT
        try:
            result = await asyncio.wait_for(
                agent_func(context), 
                timeout=self.circuit_breakers["timeout_seconds"]
            )
        except asyncio.TimeoutError:
            raise TimeoutException("Execução excedeu tempo limite")
        
        # 4. REGISTRAR CALL
        self._record_call(session_id, agent_func.__name__)
        
        return result
    
    def _detect_loop(self, session_id: str) -> bool:
        """Detecta loops analisando padrões de chamadas"""
        
        history = self.call_history.get(session_id, [])
        
        # Detectar sequências repetitivas
        if len(history) >= 6:  # Mínimo para detectar padrão
            last_3 = history[-3:]
            prev_3 = history[-6:-3]
            
            if last_3 == prev_3:
                print(f"🚨 LOOP DETECTADO: {last_3} repetindo")
                return True
        
        # Detectar agente pingando para si mesmo
        if len(history) >= 2:
            if history[-1] == history[-2]:
                print(f"🚨 AUTO-LOOP DETECTADO: {history[-1]}")
                return True
        
        return False
    
    def _check_limits_exceeded(self, session_id: str) -> bool:
        """Verifica todos os limites de segurança"""
        
        history = self.call_history.get(session_id, [])
        
        # Limite de steps por sessão
        if len(history) > self.circuit_breakers["max_steps_per_agent"] * 3:
            return True
            
        # Custo acumulado da sessão
        session_cost = self._calculate_session_cost(session_id)
        if session_cost > self.circuit_breakers["max_cost_per_session"]:
            return True
            
        return False
