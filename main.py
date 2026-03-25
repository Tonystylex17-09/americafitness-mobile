from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import datetime
from typing import List, Optional
from pydantic import BaseModel
import database
import models
import auth

# Crear las tablas en la base de datos
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI(
    title="AméricaFitness API",
    description="API para gestión de gimnasios con tienda y puntos",
    version="2.0.0"
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"message": "AméricaFitness API", "status": "online", "version": "2.0.0"}

@app.get("/health")
def health():
    return {"status": "ok"}

# ========== USUARIOS ==========
class UserCreate(BaseModel):
    username: str
    email: str
    password: str
    full_name: Optional[str] = None
    phone: Optional[str] = None
    role: Optional[str] = "user"

@app.post("/register")
def register(user: UserCreate, db: Session = Depends(database.get_db)):
    existing_user = db.query(models.User).filter(
        (models.User.username == user.username) | (models.User.email == user.email)
    ).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Usuario o email ya registrado")
    
    hashed_password = auth.get_password_hash(user.password)
    db_user = models.User(
        username=user.username,
        email=user.email,
        hashed_password=hashed_password,
        full_name=user.full_name,
        phone=user.phone,
        role=user.role
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return {"id": db_user.id, "username": db_user.username, "email": db_user.email, "role": db_user.role}

@app.post("/login")
def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(database.get_db)):
    user = db.query(models.User).filter(models.User.username == form_data.username).first()
    if not user or not auth.verify_password(form_data.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")
    
    token = auth.create_access_token(data={"sub": user.username})
    return {"access_token": token, "token_type": "bearer", "user_id": user.id, "role": user.role}

@app.get("/users/me")
def get_me(current_user: models.User = Depends(auth.get_current_user)):
    return {
        "id": current_user.id,
        "username": current_user.username,
        "email": current_user.email,
        "full_name": current_user.full_name,
        "phone": current_user.phone,
        "role": current_user.role,
        "is_active": current_user.is_active,
        "created_at": current_user.created_at
    }

# ========== GIMNASIOS ==========
class GymCreate(BaseModel):
    name: str
    address: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    phone: Optional[str] = None
    email: Optional[str] = None

@app.post("/gyms")
def create_gym(
    gym: GymCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role not in ["gym_admin", "super_admin"]:
        raise HTTPException(status_code=403, detail="No tienes permisos")
    
    db_gym = models.Gym(
        name=gym.name,
        address=gym.address,
        latitude=gym.latitude,
        longitude=gym.longitude,
        phone=gym.phone,
        email=gym.email,
        admin_id=current_user.id
    )
    db.add(db_gym)
    db.commit()
    db.refresh(db_gym)
    return db_gym

@app.get("/gyms")
def get_gyms(
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    gyms = db.query(models.Gym).offset(skip).limit(limit).all()
    return gyms

# ========== CLASES ==========
class ClassCreate(BaseModel):
    name: str
    description: Optional[str] = None
    instructor: Optional[str] = None
    capacity: int = 20
    start_time: datetime
    end_time: datetime
    gym_id: int

@app.post("/classes")
def create_class(
    class_data: ClassCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role not in ["gym_admin", "super_admin"]:
        raise HTTPException(status_code=403, detail="No tienes permisos")
    
    db_class = models.Class(
        name=class_data.name,
        description=class_data.description,
        instructor=class_data.instructor,
        capacity=class_data.capacity,
        start_time=class_data.start_time,
        end_time=class_data.end_time,
        gym_id=class_data.gym_id
    )
    db.add(db_class)
    db.commit()
    db.refresh(db_class)
    return db_class

@app.get("/classes")
def get_classes(
    gym_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    query = db.query(models.Class)
    if gym_id:
        query = query.filter(models.Class.gym_id == gym_id)
    classes = query.offset(skip).limit(limit).all()
    return classes

# ========== RESERVAS ==========
class ReservationCreate(BaseModel):
    class_id: int

@app.post("/reservations")
def create_reservation(
    reservation: ReservationCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    class_item = db.query(models.Class).filter(models.Class.id == reservation.class_id).first()
    if not class_item:
        raise HTTPException(status_code=404, detail="Clase no encontrada")
    
    reserved_count = db.query(models.Reservation).filter(
        models.Reservation.class_id == reservation.class_id,
        models.Reservation.status == "confirmed"
    ).count()
    
    if reserved_count >= class_item.capacity:
        raise HTTPException(status_code=400, detail="No hay cupos disponibles")
    
    existing = db.query(models.Reservation).filter(
        models.Reservation.user_id == current_user.id,
        models.Reservation.class_id == reservation.class_id,
        models.Reservation.status == "confirmed"
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ya reservaste esta clase")
    
    db_reservation = models.Reservation(
        user_id=current_user.id,
        class_id=reservation.class_id
    )
    db.add(db_reservation)
    db.commit()
    db.refresh(db_reservation)
    return db_reservation

@app.get("/my-reservations")
def get_my_reservations(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    reservations = db.query(models.Reservation).filter(
        models.Reservation.user_id == current_user.id
    ).all()
    return reservations

# ========== RUTINAS ==========
class RoutineCreate(BaseModel):
    name: str
    description: Optional[str] = None
    exercises: Optional[str] = None

@app.post("/routines")
def create_routine(
    routine: RoutineCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    db_routine = models.Routine(
        user_id=current_user.id,
        name=routine.name,
        description=routine.description,
        exercises=routine.exercises
    )
    db.add(db_routine)
    db.commit()
    db.refresh(db_routine)
    return db_routine

@app.get("/my-routines")
def get_my_routines(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    routines = db.query(models.Routine).filter(
        models.Routine.user_id == current_user.id
    ).all()
    return routines

# ========== CHECK-IN ==========
@app.post("/check-in")
def check_in(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    active_check_in = db.query(models.CheckIn).filter(
        models.CheckIn.user_id == current_user.id,
        models.CheckIn.check_out_time == None
    ).first()
    
    if active_check_in:
        raise HTTPException(status_code=400, detail="Ya tienes un check-in activo")
    
    new_check_in = models.CheckIn(
        user_id=current_user.id,
        gym_id=None
    )
    db.add(new_check_in)
    db.commit()
    db.refresh(new_check_in)
    
    points_record = db.query(models.UserPoints).filter(models.UserPoints.user_id == current_user.id).first()
    if not points_record:
        points_record = models.UserPoints(user_id=current_user.id, total_points=0)
        db.add(points_record)
    
    points_record.total_points += 10
    points_record.updated_at = datetime.utcnow()
    db.commit()
    
    return {
        "message": "Check-in exitoso",
        "check_in_id": new_check_in.id,
        "check_in_time": new_check_in.check_in_time,
        "points_earned": 10
    }

@app.post("/check-in-by-qr")
def check_in_by_qr(
    user_id: int,
    db: Session = Depends(database.get_db)
):
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    
    active_check_in = db.query(models.CheckIn).filter(
        models.CheckIn.user_id == user_id,
        models.CheckIn.check_out_time == None
    ).first()
    
    if active_check_in:
        raise HTTPException(status_code=400, detail="Ya tienes un check-in activo")
    
    new_check_in = models.CheckIn(
        user_id=user_id,
        gym_id=None
    )
    db.add(new_check_in)
    db.commit()
    db.refresh(new_check_in)
    
    points_record = db.query(models.UserPoints).filter(models.UserPoints.user_id == user_id).first()
    if not points_record:
        points_record = models.UserPoints(user_id=user_id, total_points=0)
        db.add(points_record)
    
    points_record.total_points += 10
    points_record.updated_at = datetime.utcnow()
    db.commit()
    
    return {
        "message": "Check-in exitoso",
        "user": user.username,
        "check_in_id": new_check_in.id,
        "check_in_time": new_check_in.check_in_time,
        "points_earned": 10
    }

@app.post("/check-out")
def check_out(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    active_check_in = db.query(models.CheckIn).filter(
        models.CheckIn.user_id == current_user.id,
        models.CheckIn.check_out_time == None
    ).first()
    
    if not active_check_in:
        raise HTTPException(status_code=400, detail="No tienes un check-in activo")
    
    active_check_in.check_out_time = datetime.utcnow()
    db.commit()
    db.refresh(active_check_in)
    
    return {
        "message": "Check-out exitoso",
        "check_in_id": active_check_in.id,
        "check_in_time": active_check_in.check_in_time,
        "check_out_time": active_check_in.check_out_time
    }

@app.get("/my-attendance")
def get_my_attendance(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    check_ins = db.query(models.CheckIn).filter(
        models.CheckIn.user_id == current_user.id
    ).order_by(models.CheckIn.check_in_time.desc()).all()
    
    return [
        {
            "id": c.id,
            "gym_id": c.gym_id,
            "check_in_time": c.check_in_time,
            "check_out_time": c.check_out_time
        }
        for c in check_ins
    ]

# ========== PUNTOS ==========
@app.get("/my-points")
def get_my_points(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    points_record = db.query(models.UserPoints).filter(models.UserPoints.user_id == current_user.id).first()
    if not points_record:
        return {"total_points": 0}
    return {"total_points": points_record.total_points}

# ========== PRODUCTOS ==========
class ProductCreate(BaseModel):
    name: str
    description: Optional[str] = None
    price: float
    points_price: Optional[int] = None
    image_url: Optional[str] = None
    stock: int = 0
    category: str = "general"

@app.post("/products")
def create_product(
    product: ProductCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    if current_user.role not in ["gym_admin", "super_admin"]:
        raise HTTPException(status_code=403, detail="No tienes permisos")
    
    db_product = models.Product(
        name=product.name,
        description=product.description,
        price=product.price,
        points_price=product.points_price,
        image_url=product.image_url,
        stock=product.stock,
        category=product.category
    )
    db.add(db_product)
    db.commit()
    db.refresh(db_product)
    return db_product

@app.get("/products")
def get_products(
    category: Optional[str] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(database.get_db)
):
    query = db.query(models.Product)
    if category:
        query = query.filter(models.Product.category == category)
    products = query.offset(skip).limit(limit).all()
    return products

# ========== CARRITO ==========
class CartItemCreate(BaseModel):
    product_id: int
    quantity: int = 1

@app.post("/cart/add")
def add_to_cart(
    item: CartItemCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
    if not product:
        raise HTTPException(status_code=404, detail="Producto no encontrado")
    
    if product.stock < item.quantity:
        raise HTTPException(status_code=400, detail="Stock insuficiente")
    
    existing = db.query(models.CartItem).filter(
        models.CartItem.user_id == current_user.id,
        models.CartItem.product_id == item.product_id
    ).first()
    
    if existing:
        existing.quantity += item.quantity
    else:
        new_item = models.CartItem(
            user_id=current_user.id,
            product_id=item.product_id,
            quantity=item.quantity
        )
        db.add(new_item)
    
    db.commit()
    return {"message": "Producto agregado al carrito"}

@app.get("/cart")
def get_cart(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    items = db.query(models.CartItem).filter(
        models.CartItem.user_id == current_user.id
    ).all()
    
    result = []
    for item in items:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        result.append({
            "id": item.id,
            "product_id": item.product_id,
            "name": product.name,
            "price": product.price,
            "points_price": product.points_price,
            "image_url": product.image_url,
            "quantity": item.quantity,
            "subtotal": product.price * item.quantity
        })
    
    total = sum(item["subtotal"] for item in result)
    return {"items": result, "total": total}

@app.delete("/cart/remove/{item_id}")
def remove_from_cart(
    item_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    item = db.query(models.CartItem).filter(
        models.CartItem.id == item_id,
        models.CartItem.user_id == current_user.id
    ).first()
    
    if not item:
        raise HTTPException(status_code=404, detail="Item no encontrado")
    
    db.delete(item)
    db.commit()
    return {"message": "Producto eliminado del carrito"}

# ========== EJERCICIOS ==========
class ExerciseCreate(BaseModel):
    name: str

@app.post("/exercises")
def create_exercise(
    exercise: ExerciseCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    existing = db.query(models.Exercise).filter(
        models.Exercise.name == exercise.name,
        models.Exercise.user_id == current_user.id
    ).first()
    if existing:
        raise HTTPException(status_code=400, detail="Ejercicio ya existe")
    
    db_exercise = models.Exercise(
        name=exercise.name,
        user_id=current_user.id
    )
    db.add(db_exercise)
    db.commit()
    db.refresh(db_exercise)
    return db_exercise

@app.get("/my-exercises")
def get_my_exercises(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    exercises = db.query(models.Exercise).filter(
        models.Exercise.user_id == current_user.id
    ).all()
    return exercises

class RecordCreate(BaseModel):
    exercise_id: int
    day_number: int
    sets: int
    weight: float
    notes: Optional[str] = None

@app.post("/exercise-record")
def add_exercise_record(
    record: RecordCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    exercise = db.query(models.Exercise).filter(
        models.Exercise.id == record.exercise_id,
        models.Exercise.user_id == current_user.id
    ).first()
    if not exercise:
        raise HTTPException(status_code=404, detail="Ejercicio no encontrado")
    
    db_record = models.ExerciseRecord(
        exercise_id=record.exercise_id,
        day_number=record.day_number,
        sets=record.sets,
        weight=record.weight,
        notes=record.notes
    )
    db.add(db_record)
    db.commit()
    db.refresh(db_record)
    return db_record

@app.get("/exercise-records/{exercise_id}")
def get_exercise_records(
    exercise_id: int,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    exercise = db.query(models.Exercise).filter(
        models.Exercise.id == exercise_id,
        models.Exercise.user_id == current_user.id
    ).first()
    if not exercise:
        raise HTTPException(status_code=404, detail="Ejercicio no encontrado")
    
    records = db.query(models.ExerciseRecord).filter(
        models.ExerciseRecord.exercise_id == exercise_id
    ).order_by(models.ExerciseRecord.day_number).all()
    return records

# ========== PAGOS ==========
class PaymentCreate(BaseModel):
    amount: int
    currency: str = "PEN"
    email: str
    description: str
    card_last4: Optional[str] = None
    card_type: Optional[str] = None

@app.post("/create-payment")
def create_payment(
    payment: PaymentCreate,
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    # Crear el pedido
    new_order = models.Order(
        user_id=current_user.id,
        total_amount=payment.amount / 100,
        status="paid"
    )
    db.add(new_order)
    db.commit()
    db.refresh(new_order)
    
    # Mover items del carrito a order_items
    cart_items = db.query(models.CartItem).filter(
        models.CartItem.user_id == current_user.id
    ).all()
    
    for item in cart_items:
        product = db.query(models.Product).filter(models.Product.id == item.product_id).first()
        order_item = models.OrderItem(
            order_id=new_order.id,
            product_id=item.product_id,
            quantity=item.quantity,
            price=product.price
        )
        db.add(order_item)
        db.delete(item)
    
    db.commit()
    
    return {
        "success": True,
        "charge_id": "simulacion_" + str(datetime.now().timestamp()),
        "message": "Pago procesado exitosamente",
        "order_id": new_order.id
    }

# ========== PEDIDOS ==========
@app.get("/my-orders")
def get_my_orders(
    db: Session = Depends(database.get_db),
    current_user: models.User = Depends(auth.get_current_user)
):
    orders = db.query(models.Order).filter(
        models.Order.user_id == current_user.id
    ).order_by(models.Order.created_at.desc()).all()
    
    result = []
    for order in orders:
        items = db.query(models.OrderItem).filter(
            models.OrderItem.order_id == order.id
        ).all()
        result.append({
            "id": order.id,
            "total_amount": order.total_amount,
            "status": order.status,
            "created_at": order.created_at.isoformat(),
            "items": [{"product_name": item.product.name, "quantity": item.quantity, "price": item.price} for item in items]
        })
    return result

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)