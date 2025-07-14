import logging
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse

from .recipes_semantic import router as recipes_router
from .ingredient_recognition_semantic import router as ingredients_router
from .ingredient_recognition import router as simple_recognition_router
from .recipe_adaptation_semantic import router as adaptation_router


def create_app() -> FastAPI:
    app = FastAPI()

    app.include_router(recipes_router)
    app.include_router(ingredients_router)
    app.include_router(simple_recognition_router)
    app.include_router(adaptation_router)

    logger = logging.getLogger("chefito.api")

    @app.exception_handler(HTTPException)
    async def http_exception_handler(request: Request, exc: HTTPException):
        return JSONResponse(status_code=exc.status_code, content={"detail": exc.detail})

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(request: Request, exc: Exception):
        logger.exception("Unhandled error: %s", exc)
        return JSONResponse(status_code=500, content={"detail": "Internal Server Error"})

    return app

