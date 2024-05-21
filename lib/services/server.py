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

@app.post("/write/")
async def write(request: Request):
    form = await request.form()

    if not form:
        raise HTTPException(status_code=400, detail="No data provided")
    
    branch = form.get('branch')
    data = {
        'name': form.get('name'),
        'designation': form.get('position'),  # Assuming your position field corresponds to designation
        'value': form.get('todays_allowance')  # Modify this accordingly based on your form fields
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
            start_date = datetime.datetime.now()
            headers = ["Name", "Designation", "Total KM", "Total DA"] + \
                      [f"Day {i+1} ({(start_date + datetime.timedelta(days=i)).strftime('%Y-%m-%d')})" for i in range(15)]
            sheet.append_row(headers)

        # Find or add employee row
        cell = sheet.find(data['name'], in_column=1)
        if not cell:
            # New employee
            index = len(sheet.col_values(1)) + 1  # next available row
            sheet.append_row([data['name'], data['designation']] + [''] * (14*4), index)  # Extend row with placeholders
        else:
            index = cell.row

        # Determine the day column based on the current date
        start_date = datetime.datetime.now() - datetime.timedelta(days=1)  # Starting yesterday for the day to be correct on the spreadsheet
        day_index = (datetime.datetime.now() - start_date).days
        day_column = 5 + day_index  # assuming 4 initial columns, adjust if your header count changes

        # Write or update data in the corresponding day's column
        current_value = sheet.cell(index, day_column).value
        if not current_value:
            sheet.update_cell(index, day_column, data['value'])  # Assuming 'value' key in data dict contains the entry

        return JSONResponse(content={"message": "Data written successfully"})
    except Exception as e:
        logging.exception("Error occurred while writing data:")
        raise HTTPException(status_code=500, detail=str(e))
