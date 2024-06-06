from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
import gspread
from oauth2client.service_account import ServiceAccountCredentials
import logging
import datetime

app = FastAPI()

# Set up CORS
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://127.0.0.1:8000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# Set up logging
logging.basicConfig(level=logging.DEBUG)

scope = ["https://spreadsheets.google.com/feeds", 'https://www.googleapis.com/auth/spreadsheets', "https://www.googleapis.com/auth/drive.file", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name('service-account.json', scope)
client = gspread.authorize(creds)

sheet_id = "19lBAT1N_Vuu-d1GAOGEfgZ1WAHFoHjglZRv3sIWiXKg" 

def calculate_daily_allowance(designation, shift, is_sunday, km_travelled):
    daily_allowance = 3.2 * km_travelled

    if designation == 'BM':
        daily_allowance += 90 if shift == 'Day' else 120
    elif designation == 'ABM':
        daily_allowance += 75 if shift == 'Day' else 120
    elif designation == 'LS':
        daily_allowance += 60 if shift == 'Day' else 120
    elif designation == 'WS':
        daily_allowance += 100 if shift == 'Day' else 60
        if is_sunday:
            daily_allowance += 100

    return daily_allowance

@app.options("/write/")
async def options_handler():
    return JSONResponse(content="OK", status_code=200)

@app.post("/write/")
async def write(request: Request):
    form = await request.json()

    if not form:
        raise HTTPException(status_code=400, detail="No data provided")
    
    branch = form.get('branch')
    name = form.get('name')
    designation = form.get('position')
    shift = form.get('day')  
    opening_km = float(form.get('openingKm'))
    closing_km = float(form.get('closingKm'))
    km_travelled = float(form.get('km_travelled_today'))
    is_sunday = form.get('is_sunday', False)
    daily_allowance = calculate_daily_allowance(designation, shift, is_sunday, km_travelled)

    if not branch:
        raise HTTPException(status_code=400, detail="Branch not provided")

    try:
        # Load or create a sheet for the specified branch
        workbook = client.open_by_key(sheet_id)
        try:
            sheet = workbook.worksheet(branch)
        except gspread.WorksheetNotFound:
            sheet = workbook.add_worksheet(title=branch, rows="100", cols="50")
            # Initialize the sheet with headers if new
            headers = ["Name", "Designation", "Opening Km", "Closing Km", "KM Travelled Today", "Daily Allowance"]
            sheet.append_row(headers)

        # Find or add employee row
        cell = sheet.find(name, in_column=1)
        if not cell:
            # New employee
            sheet.append_row([name, designation, opening_km, closing_km, km_travelled, daily_allowance])
        else:
            index = cell.row
            row_values = sheet.row_values(index)
            first_empty_col = len(row_values) + 1  # get index of the first empty cell in the row
            # Append data in the first empty cell in the row for the same employee
            update_range = f"{chr(64 + first_empty_col)}{index}:{chr(64 + first_empty_col + 3)}{index}"
            sheet.update(update_range, [[opening_km, closing_km, km_travelled, daily_allowance]])

        return JSONResponse(content={"message": "Data written successfully"})
    except Exception as e:
        logging.exception("Error occurred while writing data:")
        raise HTTPException(status_code=500, detail="Internal Server Error")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
