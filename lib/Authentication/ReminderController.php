<?php

namespace App\Http\Controllers;

use App\Models\Reminder;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ReminderController extends Controller
{
    /**
     * Display a listing of the user's reminders.
     */
    public function index()
    {
        $reminders = Reminder::where('user_id', Auth::id())->with('medication')->get();

        return response()->json($reminders);
    }

    /**
     * Store a newly created reminder in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'medication_id' => 'required|exists:medications,id',
            'reminder_time' => 'required|date_format:H:i',
            'notes' => 'nullable|string',
        ]);

        // Ensure the medication belongs to the user
        $medication = Auth::user()->medications()->find($validated['medication_id']);
        if (!$medication) {
            return response()->json(['message' => 'Medication not found or does not belong to the user.'], 403);
        }

        $reminder = Reminder::create([
            'user_id' => Auth::id(),
            'medication_id' => $validated['medication_id'],
            'reminder_time' => $validated['reminder_time'],
            'notes' => $validated['notes'] ?? null,
        ]);

        return response()->json([
            'message' => 'Reminder created successfully.',
            'data' => $reminder
        ], 201);
    }

    /**
     * Display the specified reminder.
     */
    public function show(Reminder $reminder)
    {
        // Authorize that the reminder belongs to the user
        if ($reminder->user_id !== Auth::id()) {
            return response()->json(['message' => 'Not authorized to view this reminder.'], 403);
        }

        return response()->json($reminder->load('medication'));
    }

    /**
     * Update the specified reminder in storage.
     */
    public function update(Request $request, Reminder $reminder)
    {
        // Authorize that the reminder belongs to the user
        if ($reminder->user_id !== Auth::id()) {
            return response()->json(['message' => 'Not authorized to update this reminder.'], 403);
        }

        $validated = $request->validate([
            'reminder_time' => 'sometimes|required|date_format:H:i',
            'active' => 'sometimes|boolean',
            'notes' => 'nullable|string',
        ]);

        $reminder->update($validated);

        return response()->json([
            'message' => 'Reminder updated successfully.',
            'data' => $reminder
        ]);
    }

    /**
     * Remove the specified reminder from storage.
     */
    public function destroy(Reminder $reminder)
    {
        // Authorize that the reminder belongs to the user
        if ($reminder->user_id !== Auth::id()) {
            return response()->json(['message' => 'Not authorized to delete this reminder.'], 403);
        }

        $reminder->delete();

        return response()->json(['message' => 'Reminder deleted successfully.']);
    }
}