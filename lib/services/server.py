from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse
import gspread
from oauth2client.service_account import ServiceAccountCredentials
from fastapi.middleware.cors import CORSMiddleware
import logging
import datetime

app = FastAPI()

# Set up CORS
origins = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

scope = ["https://spreadsheets.google.com/feeds", 'https://www.googleapis.com/auth/spreadsheets', "https://www.googleapis.com/auth/drive.file", "https://www.googleapis.com/auth/drive"]
creds = ServiceAccountCredentials.from_json_keyfile_name('service-account.json', scope)
client = gspread.authorize(creds)

sheet_id = "19lBAT1N_Vuu-d1GAOGEfgZ1WAHFoHjglZRv3sIWiXKg" 

# Set up logging
logging.basicConfig(level=logging.DEBUG)

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

@app.post("/write/")
async def write(request: Request):
    form = await request.json()

    if not form:
        raise HTTPException(status_code=400, detail="No data provided")
    
    branch = form.get('branch')
    name = form.get('name')
    designation = form.get('position')
    shift = form.get('day')  # Assuming the day value is provided as 'Day' or 'Night'
    km_travelled = float(form.get('km_travelled_today'))
    is_sunday = form.get('is_sunday', False)
    daily_allowance = calculate_daily_allowance(designation, shift, is_sunday, km_travelled)

    data = {
        'name': name,
        'designation': designation,
        'km_travelled': km_travelled,
        'daily_allowance': daily_allowance
    }
    if not branch or not data:
        raise HTTPException(status_code=400, detail="Branch or data not provided")

    try:
        # Load or create a sheet for the specified branch
        try:
            workbook = client.open_by_key(sheet_id)
            sheet = workbook.worksheet(branch)
        except gspread.WorksheetNotFound:
            workbook = client.open_by_key(sheet_id)
            sheet = workbook.add_worksheet(title=branch, rows="100", cols="50")
            # Initialize the sheet with headers if new
            headers = ["Name", "Designation", "Total KM", "Total DA"]
            sheet.append_row(headers)

        # Find or add employee row
        cell = sheet.find(data['name'], in_column=1)
        if not cell:
            # New employee
            index = len(sheet.col_values(1)) + 1  # next available row
            sheet.append_row([data['name'], data['designation'], data['km_travelled'], data['daily_allowance']])
        else:
            index = cell.row
            current_km = float(sheet.cell(index, 3).value or 0)
            current_da = float(sheet.cell(index, 4).value or 0)
            sheet.update_cell(index, 3, current_km + data['km_travelled'])
            sheet.update_cell(index, 4, current_da + data['daily_allowance'])

        return JSONResponse(content={"message": "Data written successfully"})
    except Exception as e:
        logging.exception("Error occurred while writing data:")
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="127.0.0.1", port=8000)
